--[[
  Name: ban
  Desc: Ban a player
  Arguments:
    1. Target   (player)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.SetupCommand("ban", function(cmd)
  cmd:SetDescription("Ban a player")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local target = self:GetPlayerArg(1, true)
    self:CheckCanTarget(target, true) -- make sure ply is allowed to target this person
    local duration = self:GetNumberArg(2)
    local reason
    if duration then
      duration = math.max(duration, 0)
      reason = self:GetMultiStringArg(3, -1)
    else
      reason = self:GetMultiStringArg(2, -1)
    end

    BSU.BanPlayer(target, reason, duration, ply)

    self:BroadcastActionMsg("%user% banned %param%" .. (duration and duration ~= 0 and " for %param%" or " permanently") .. (reason and " (%param%)" or ""), {
      ply,
      target,
      duration and duration ~= 0 and BSU.StringTime(duration, 10000),
      reason
    })
  end)
end)

--[[
  Name: banid
  Desc: Ban a player by steamid
  Arguments:
    1. Steam ID (string)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.SetupCommand("banid", function(cmd)
  cmd:SetDescription("Ban a player by steamid")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local steamid = BSU.ID64(self:GetStringArg(1, true))
    self:CheckCanTargetID(steamid, true) -- make sure ply is allowed to target this person
    local duration = self:GetNumberArg(2)
    local reason
    if duration then
      duration = math.max(duration, 0)
      reason = self:GetMultiStringArg(3, -1)
    else
      reason = self:GetMultiStringArg(2, -1)
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
end)

--[[
  Name: ipban
  Desc: IP ban a player
  Arguments:
    1. Target   (player)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.SetupCommand("ipban", function(cmd)
  cmd:SetDescription("IP ban a player")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local target = self:GetPlayerArg(1, true)
    self:CheckCanTarget(target, true) -- make sure ply is allowed to target this person
    local duration = self:GetNumberArg(2)
    local reason
    if duration then
      duration = math.max(duration, 0)
      reason = self:GetMultiStringArg(3, -1)
    else
      reason = self:GetMultiStringArg(2, -1)
    end
  
    BSU.IPBanPlayer(target, reason, duration, ply)
  
    self:BroadcastActionMsg("%user% ip banned %param%" .. (duration and duration ~= 0 and " for %param%" or " permanently") .. (reason and " (%param%)" or ""), {
      ply,
      target,
      duration and duration ~= 0 and BSU.StringTime(duration, 10000),
      reason
    })
  end)
end)

--[[
  Name: banip
  Desc: Ban a player by ip
  Arguments:
    1. IP Address (string)
    2. Duration   (number) (optional)
    3. Reason     (string) (optional)
]]
BSU.SetupCommand("banip", function(cmd)
  cmd:SetDescription("Ban a player by ip")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local address = BSU.Address(self:GetStringArg(1, true))
    local targetData = BSU.GetPlayerDataByIPAddress(address) -- find any players associated with this address
    for i = 1, #targetData do -- make sure ply is allowed to target all of these players
      self:CheckCanTargetID(targetData[i].steamid, true)
    end
    local duration = self:GetNumberArg(2)
    local reason
    if duration then
      duration = math.max(duration, 0)
      reason = self:GetMultiStringArg(3, -1)
    else
      reason = self:GetMultiStringArg(2, -1)
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
end)

--[[
  Name: unban
  Desc: Unban a player
  Arguments:
    1. Steam ID (string)
]]
BSU.SetupCommand("unban", function(cmd)
  cmd:SetDescription("Unban a player")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local steamid = self:GetStringArg(1, true)
    steamid = BSU.ID64(steamid)
  
    BSU.RevokeSteamIDBan(steamid, ply:IsValid() and ply:SteamID64()) -- this also checks if the steam id is actually banned
  
    local name = BSU.GetPlayerDataBySteamID(steamid).name
    self:BroadcastActionMsg("%user% unbanned %param%" .. (name and " (%param%)" or ""), {
      ply,
      util.SteamIDFrom64(steamid),
      name
    })
  end)
end)

--[[
  Name: unbanip
  Desc: Unban a player by ip
  Arguments:
    1. IP Address (string)
]]
BSU.SetupCommand("unbanip", function(cmd)
  cmd:SetDescription("Unban a player by ip")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local address = self:GetStringArg(1, true)
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
end)

--[[
  Name: superban
  Desc: Equivalent to the ban command, except it will also ban the account that owns the game license if the player is using Steam Family Sharing
  Arguments:
    1. Target   (player)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.SetupCommand("superban", function(cmd)
  cmd:SetDescription("Equivalent to the ban command, except it will also ban the account that owns the game license if the player is using Steam Family Sharing")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_SUPERADMIN)
  cmd:SetFunction(function(self, ply, _, argStr)
    local target = self:GetPlayerArg(1, true)
  
    BSU.RunCommand("ban", ply, argStr)
  
    local ownerID = target:OwnerSteamID64()
    if ownerID ~= target:SteamID64() then
      BSU.RunCommand("banid", ply, ownerID .. " " .. (self:GetRawMultiStringArg(2, -1) or ""))
    end
  end)
end)

--[[
  Name: superduperban
  Desc: Equivalent to the superban command, except it will also ip ban the player
  Arguments:
    1. Target   (player)
    2. Duration (number) (optional)
    3. Reason   (string) (optional)
]]
BSU.SetupCommand("superduperban", function(cmd)
  cmd:SetDescription("Equivalent to the superban command, except it will also ip ban the player")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_SUPERADMIN)
  cmd:SetFunction(function(self, ply, _, argStr)
    BSU.RunCommand("superban", ply, argStr)
    BSU.RunCommand("ipban", ply, argStr)
  end)
end)

--[[
  Name: kick
  Desc: Kick a player
  Arguments:
    1. Target (player)
    2. Reason (string) (optional)
]]
BSU.SetupCommand("kick", function(cmd)
  cmd:SetDescription("Kick a player")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local target = self:GetPlayerArg(1, true)
    self:CheckCanTarget(target, true)
    local reason = self:GetMultiStringArg(2, -1)
  
    BSU.KickPlayer(target, reason, ply)
  
    self:BroadcastActionMsg("%user% kicked %param%" .. (reason and " (%param%)" or ""), {
      ply,
      target,
      reason
    })
  end)
end)

--[[
  Name: listgroups
  Desc: Show a list of all groups
]]
BSU.SetupCommand("listgroups", function(cmd)
  cmd:SetDescription("Show a list of all groups")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_SUPERADMIN)
  cmd:SetFunction(function(self, ply)
    local groups = BSU.GetAllGroups()
    table.sort(groups, function(a, b) return a.id < b.id end)

    local msg = { color_white, "Groups List:\n" }
    for k, v in ipairs(groups) do
      table.Add(msg, {
        color_white, v.id .. ")\t", BSU.HexToColor(v.color), v.name .. "\n"
      })
    end

    self:SendChatMsg(unpack(msg))
  end)
end)

--[[
  Name: setgroup
  Desc: Set the group of a player
  Arguments:
    1. Target (player)
    2. Group ID (string)
]]
BSU.SetupCommand("setgroup", function(cmd)
  cmd:SetDescription("Set the group of a player")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_SUPERADMIN)
  cmd:SetFunction(function(self, ply)
    local target, groupid = self:GetPlayerArg(1, true), self:GetStringArg(2, true)

    if not BSU.GetGroupByID(groupid) then error("Group does not exist") end
    if BSU.GetPlayerData(target).groupid == groupid then error("Target is already in that group") end

    BSU.SetPlayerGroup(target, groupid)

    self:BroadcastActionMsg("%user% set the group of %param% to %param%", {
      ply,
      target,
      groupid
    })
  end)
end)

--[[
  Name: setteam
  Desc: Set the team of a player
  Arguments:
    1. Target (player)
    2. Team Index (number) (optional, resets team to the group team if not set)
]]
BSU.SetupCommand("setteam", function(cmd)
  cmd:SetDescription("Set the team of a player")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_SUPERADMIN)
  cmd:SetFunction(function(self, ply)
    local target, team = self:GetPlayerArg(1, true), self:GetNumberArg(2)

    local teamData
    if team then
      teamData = BSU.GetTeamByID(team)
    else
      teamData = BSU.GetTeamByName(self:GetMultiStringArg(2, -1, true))
    end

    if not teamData then error("Team does not exist") end
    if BSU.GetPlayerData(target).team == teamData.id then error("Target is already in that team") end

    BSU.SetPlayerTeam(target, teamData.id)

    self:BroadcastActionMsg("%user% set the team of %param% to %param%", {
      ply,
      target,
      teamData.name
    })
  end)
end)

--[[
  Name: resetteam
  Desc: Reset the team of a player to use their group's team instead
  Arguments:
    1. Target (Player)
]]
BSU.SetupCommand("resetteam", function(cmd)
  cmd:SetDescription("Reset the team of a player to use their group's team instead")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_SUPERADMIN)
  cmd:SetFunction(function(self, ply)
    local target = self:GetPlayerArg(1, true)

    BSU.ResetPlayerTeam(target)

    self:BroadcastActionMsg("%user% reset the team of %param%", {
      ply,
      target
    })
  end)
end)

local privs = {
  model = BSU.PRIV_MODEL,
  mdl = BSU.PRIV_MODEL,
  npc = BSU.PRIV_NPC,
  sent = BSU.PRIV_SENT,
  entity = BSU.PRIV_SENT,
  swep = BSU.PRIV_SWEP,
  weapon = BSU.PRIV_SWEP,
  tool = BSU.PRIV_TOOL,
  command = BSU.PRIV_CMD,
  cmd = BSU.PRIV_CMD
}

local function getPrivFromName(name)
  return privs[string.lower(name)]
end

local names = {
  [BSU.PRIV_MODEL] = "model",
  [BSU.PRIV_NPC] = "npc",
  [BSU.PRIV_SENT] = "entity",
  [BSU.PRIV_SWEP] = "weapon",
  [BSU.PRIV_TOOL] = "tool",
  [BSU.PRIV_CMD] = "command"
}

local function getNameFromPriv(priv)
  return names[priv]
end

--[[
  Name: addgrouppriv
  Desc: Set a group to have access to a privilege
  Arguments:
    1. Group ID (number)
    2. Name (string)
    3. Value (string)
]]
BSU.SetupCommand("grantgrouppriv", function(cmd)
  cmd:SetDescription("Set a group to have access to a privilege")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_SUPERADMIN)
  cmd:SetFunction(function(self, ply)
    local groupid, name, value = self:GetNumberArg(1, true), self:GetStringArg(2, true), self:GetStringArg(3, true)

    local group = BSU.GetGroupByID(groupid)
    if not group then error("Group does not exist") end
    if group.usergroup == "superadmin" then error("Group is in the 'superadmin' usergroup and thus already has access to everything") end

    local type = getPrivFromName(name)
    if not type then error("Unknown privilege type") end

    local priv = BSU.SQLSelectByValues(BSU.SQL_GROUP_PRIVS, { groupid = groupid, type = type, value = value })[1]
    if priv and priv.granted == 1 then error("Privilege is already granted to this group") end

    BSU.RegisterGroupPrivilege(groupid, type, value, true)

    self:BroadcastActionMsg("%user% granted the group %param% access to %param% (%param%)", {
      ply,
      group.name,
      value,
      getNameFromPriv(type)
    })
  end)
end)

--[[
  Name: revokegrouppriv
  Desc: Set a group to not have access to a privilege
  Arguments:
    1. Group ID (number)
    2. Name (string)
    3. Value (string)
]]
BSU.SetupCommand("revokegrouppriv", function(cmd)
  cmd:SetDescription("Set a group to not have access to a privilege")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_SUPERADMIN)
  cmd:SetFunction(function(self, ply)
    local groupid, name, value = self:GetNumberArg(1, true), self:GetStringArg(2, true), self:GetStringArg(3, true)

    local group = BSU.GetGroupByID(groupid)
    if not group then error("Group does not exist") end
    if group.usergroup == "superadmin" then error("Group is in the 'superadmin' usergroup and thus cannot be restricted from anything") end

    local type = getPrivFromName(name)
    if not type then error("Unknown privilege type") end

    local priv = BSU.SQLSelectByValues(BSU.SQL_GROUP_PRIVS, { groupid = groupid, type = type, value = value })[1]
    if priv and priv.granted == 0 then error("Privilege is already revoked from this group") end

    BSU.RegisterGroupPrivilege(groupid, type, value, false)

    self:BroadcastActionMsg("%user% revoked the group %param% access from %param% (%param%)", {
      ply,
      group.name,
      value,
      getNameFromPriv(type)
    })
  end)
end)

--[[
  Name: cleargrouppriv
  Desc: Remove an existing group privilege (will then use whatever the default accessibility is for the group)
  Arguments:
    1. Group ID (number)
    2. Name (string)
    3. Value (string)
]]
BSU.SetupCommand("cleargrouppriv", function(cmd)
  cmd:SetDescription("Remove an existing group privilege (will use whatever the default access settings are)")
  cmd:SetCategory("moderation")
  cmd:SetAccess(BSU.CMD_SUPERADMIN)
  cmd:SetFunction(function(self, ply)
    local groupid, name, value = self:GetNumberArg(1, true), self:GetStringArg(2, true), self:GetStringArg(3, true)

    local group = BSU.GetGroupByID(groupid)
    if not group then error("Group does not exist") end

    local type = getPrivFromName(name)
    if not type then error("Unknown privilege type") end

    local priv = BSU.SQLSelectByValues(BSU.SQL_GROUP_PRIVS, { groupid = groupid, type = type, value = value })[1]
    if not priv then error("Privilege on this group doesn't exist") end

    BSU.RemoveGroupPrivilege(groupid, type, value)

    self:BroadcastActionMsg("%user% cleared a %param% privilege on the group %param% for %param% (%param%)", {
      ply,
      priv.granted == 1 and "granting" or "revoking",
      group.name,
      value,
      getNameFromPriv(type),
    })
  end)
end)