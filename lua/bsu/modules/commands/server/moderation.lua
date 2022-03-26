--[[
  Name: ban
  Desc: Ban a player
  Arguments:
    1. Target   (player)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.CreateCommand("ban", "Ban a player", BSU.CMD_ADMIN, function(self, ply)
  local target = self:GetPlayer(1, true)
  self:CheckCanTarget(target, true) -- make sure ply is allowed to target this person
  local duration = self:GetNumber(2)
  local reason
  if duration then
    duration = math.max(duration, 0)
    reason = self:GetMultiString(3, -1)
  else
    reason = self:GetMultiString(2, -1)
  end

  BSU.BanPlayer(target, reason, duration, ply)

  self:BroadcastActionMsg("%user% banned %param%" .. (duration and duration ~= 0 and " for %param%" or " permanently") .. (reason and " (%param%)" or ""), {
    ply,
    target,
    duration and duration ~= 0 and BSU.StringTime(duration, 10000),
    reason
  })
end)

--[[
  Name: banid
  Desc: Ban a player by steamid
  Arguments:
    1. Steam ID (string)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.CreateCommand("banid", "Ban a player by steamid", BSU.CMD_ADMIN, function(self, ply)
  local steamid = BSU.ID64(self:GetString(1, true))
  self:CheckCanTargetID(steamid, true) -- make sure ply is allowed to target this person
  local duration = self:GetNumber(2)
  local reason
  if duration then
    duration = math.max(duration, 0)
    reason = self:GetMultiString(3, -1)
  else
    reason = self:GetMultiString(2, -1)
  end

  BSU.BanSteamID(steamid, reason, duration, ply:IsValid() and ply:SteamID64())

  local name = BSU.GetPlayerDataBySteamID(steamid).name
  self:BroadcastActionMsg("%user% banned steamid %param%" .. (name and " (%param%)" or "") .. (duration and duration ~= 0 and " for %param%" or " permanently") .. (reason and " (%param%)" or ""), {
    ply,
    util.SteamIDFrom64(steamid),
    name,
    duration and duration ~= 0 and BSU.StringTime(duration, 10000),
    reason
  })
end)

--[[
  Name: ipban
  Desc: IP ban a player
  Arguments:
    1. Target   (player)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.CreateCommand("ipban", "IP ban a player", BSU.CMD_ADMIN, function(self, ply)
  local target = self:GetPlayer(1, true)
  self:CheckCanTarget(target, true) -- make sure ply is allowed to target this person
  local duration = self:GetNumber(2)
  local reason
  if duration then
    duration = math.max(duration, 0)
    reason = self:GetMultiString(3, -1)
  else
    reason = self:GetMultiString(2, -1)
  end

  BSU.IPBanPlayer(target, reason, duration, ply)

  self:BroadcastActionMsg("%user% ip banned %param%" .. (duration and duration ~= 0 and " for %param%" or " permanently") .. (reason and " (%param%)" or ""), {
    ply,
    target,
    duration and duration ~= 0 and BSU.StringTime(duration, 10000),
    reason
  })
end)

--[[
  Name: banip
  Desc: Ban a player by ip
  Arguments:
    1. IP Address (string)
    2. Duration   (number) (optional)
    3. Reason     (string) (optional)
]]
BSU.CreateCommand("banip", "Ban a player by ip", BSU.CMD_ADMIN, function(self, ply)
  local address = BSU.Address(self:GetString(1, true))
  local targetData = BSU.GetPlayerDataByIPAddress(address) -- find any players associated with this address
  for i = 1, #targetData do -- make sure ply is allowed to target all of these players
    self:CheckCanTargetID(targetData[i].steamid, true)
  end
  local duration = self:GetNumber(2)
  local reason
  if duration then
    duration = math.max(duration, 0)
    reason = self:GetMultiString(3, -1)
  else
    reason = self:GetMultiString(2, -1)
  end

  BSU.BanIP(address, reason, duration, ply:IsValid() and ply:SteamID64())

  local names = {}
  for i = 1, #targetData do
    table.insert(names, targetData[i].name)
  end
  self:BroadcastActionMsg("%user% banned an ip" .. (not table.IsEmpty(names) and " (%param%)" or "") .. (duration and duration ~= 0 and " for %param%" or " permanently") .. (reason and " (%param%)" or ""), {
    ply,
    not table.IsEmpty(names) and names,
    duration and duration ~= 0 and BSU.StringTime(duration, 10000),
    reason
  })
end)

--[[
  Name: unban
  Desc: Unban a player
  Arguments:
    1. Steam ID (string)
]]
BSU.CreateCommand("unban", "Unban a player", BSU.CMD_ADMIN, function(self, ply)
  local steamid = self:GetString(1, true)
  steamid = BSU.ID64(steamid)

  BSU.RevokeSteamIDBan(steamid, ply:IsValid() and ply:SteamID64()) -- this also checks if the steam id is actually banned

  local name = BSU.GetPlayerDataBySteamID(steamid).name
  self:BroadcastActionMsg("%user% unbanned %param%" .. (name and " (%param%)" or ""), {
    ply,
    util.SteamIDFrom64(steamid),
    name
  })
end)

--[[
  Name: unbanip
  Desc: Unban a player by ip
  Arguments:
    1. IP Address (string)
]]
BSU.CreateCommand("unbanip", "Unban a player by ip", BSU.CMD_ADMIN, function(self, ply)
  local address = self:GetString(1, true)
  address = BSU.Address(address)

  BSU.RevokeIPBan(address, ply:IsValid() and ply:SteamID64()) -- this also checks if the steam id is actually banned

  local targetData, names = BSU.GetPlayerDataByIPAddress(address), {}
  for i = 1, #targetData do -- get all the names of players associated with the address
    table.insert(names, targetData[i].name)
  end
  self:BroadcastActionMsg("%user% unbanned an ip" .. (not table.IsEmpty(names) and " (%param%)" or ""), {
    ply,
    not table.IsEmpty(names) and names
  })
end)

--[[
  Name: superban
  Desc: Equivalent to the ban command, except if a player is using Steam Family Sharing, the account that owns the Garry's Mod license will also be banned
  Arguments:
    1. Target   (player)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.CreateCommand("superban", "Equivalent to the ban command, except if a player is using Steam Family Sharing, the account that owns the Garry's Mod license will also be banned", BSU.CMD_SUPERADMIN, function(self, ply, _, argStr)
  local target = self:GetPlayer(1, true)

  BSU.RunCommand("ban", ply, argStr)

  local ownerID = target:OwnerSteamID64()
  if ownerID ~= target:SteamID64() then
    BSU.RunCommand("banid", ply, ownerID .. " " .. (self:GetRawMultiString(2, -1) or ""))
  end
end)

--[[
  Name: superduperban
  Desc: Equivalent to the superban command, except it will also ip ban the player
  Arguments:
    1. Target   (player)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.CreateCommand("superduperban", "Equivalent to the superban command, except it will also ip ban the player", BSU.CMD_SUPERADMIN, function(self, ply, _, argStr)
  BSU.RunCommand("superban", ply, argStr)
  BSU.RunCommand("ipban", ply, argStr)
end)

--[[
  Name: kick
  Desc: Kick a player
  Arguments:
    1. Target (player)
    2. Reason (string) (optional)
]]
BSU.CreateCommand("kick", "Kick a player", BSU.CMD_ADMIN, function(self, ply)
  local target = self:GetPlayer(1, true)
  self:CheckCanTarget(target, true)
  local reason = self:GetMultiString(2, -1)

  BSU.KickPlayer(target, reason, ply)

  self:BroadcastActionMsg("%user% kicked %param%" .. (reason and " (%param%)" or ""), {
    ply,
    target,
    reason
  })
end)