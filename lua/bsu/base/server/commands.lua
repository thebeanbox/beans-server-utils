-- base/server/commands.lua

BSU.CreateCommand("nothing", "Do nothing to a player", nil, function(self, ply)
  print(self)
  local targets = self:GetPlayers(1, true)
  self:SendActionMsg(color_white, " did nothing to ", unpack(targets))
end)

BSU.CreateCommand("ban", "Ban a player", BSU.CMD_ADMIN_ONLY, function(self, ply)
  local target, duration, reason = self:GetPlayer(1, true), self:GetNumber(2), self:GetRawMultiString(3, -1)
  if duration then duration = math.min(duration, 0) end
  BSU.BanPlayer(target, reason, duration, ply)
  self:SendActionMsg(color_white, " banned ", target, color_white, (duration and duration ~= 0 and " for " .. BSU.StringTime(duration * 60) or " permanently") .. (reason and " (" .. reason .. ")" or ""))
end)

BSU.CreateCommand("banid", "Ban a player by steam ID", BSU.CMD_ADMIN_ONLY, function(self, ply)
  local steamid, duration, reason = self:GetString(1, true), self:GetNumber(2), self:GetRawMultiString(3, -1)
  steamid = BSU.ID64(steamid)
  if duration then duration = math.min(duration, 0) end
  BSU.BanSteamID(steamid, reason, duration, ply:SteamID64())
  self:SendActionMsg(color_white, " banned steam ID ", Color(0, 255, 0), util.SteamIDFrom64(steamid), color_white, (duration and duration ~= 0 and " for " .. BSU.StringTime(duration * 60) or " permanently") .. (reason and " (" .. reason .. ")" or ""))
end)

BSU.CreateCommand("kick", "Kick a player", BSU.CMD_ADMIN_ONLY, function(self, ply)
  local target, reason = self:GetPlayer(1, true), self:GetRawMultiString(2, -1)
  BSU.KickPlayer(target, reason, ply)
  self:SendActionMsg(color_white, " kicked ", target, color_white, reason and " (" .. reason .. ")" or "")
end)