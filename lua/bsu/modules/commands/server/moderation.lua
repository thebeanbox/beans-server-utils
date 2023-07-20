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
	cmd:SetFunction(function(self)
		local target = self:GetPlayerArg(1, true)
		self:CheckCanTarget(target, true) -- make sure caller is allowed to target this person

		local duration = self:GetNumberArg(2)
		local reason
		if duration then
			duration = math.max(duration, 0)
			reason = self:GetMultiStringArg(3, -1)
		else
			duration = 0 -- permaban
			reason = self:GetMultiStringArg(2, -1)
		end

		self:BroadcastActionMsg("%caller% banned %target%<%steamid%>" .. (duration ~= 0 and " for %duration%" or " permanently") .. (reason and " (%reason%)" or ""), {
			target = target,
			steamid = target:SteamID(),
			duration = duration ~= 0 and BSU.StringTime(duration, 10000) or nil,
			reason = reason
		})

		BSU.BanPlayer(target, reason, duration, self:GetCaller())
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
	cmd:SetFunction(function(self)
		local steamid = BSU.ID64(self:GetStringArg(1, true))
		self:CheckCanTargetSteamID(steamid, true) -- make sure caller is allowed to target this person

		local duration = self:GetNumberArg(2)
		local reason
		if duration then
			duration = math.max(duration, 0)
			reason = self:GetMultiStringArg(3, -1)
		else
			duration = 0 -- permaban
			reason = self:GetMultiStringArg(2, -1)
		end

		local ply = self:GetCaller()
		BSU.BanSteamID(steamid, reason, duration, ply:IsValid() and ply:SteamID64())

		local name = BSU.GetPlayerDataBySteamID(steamid).name

		self:BroadcastActionMsg("%caller% banned steamid %steamid%" .. (name and " (%name%)" or "") .. (duration ~= 0 and " for %duration%" or " permanently") .. (reason and " (%reason%)" or ""), {
			steamid = util.SteamIDFrom64(steamid),
			name = name,
			duration = duration ~= 0 and BSU.StringTime(duration, 10000) or nil,
			reason = reason
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
	cmd:SetFunction(function(self)
		local target = self:GetPlayerArg(1, true)
		self:CheckCanTarget(target, true) -- make sure caller is allowed to target this person

		local duration = self:GetNumberArg(2)
		local reason
		if duration then
			duration = math.max(duration, 0)
			reason = self:GetMultiStringArg(3, -1)
		else
			duration = 0
			reason = self:GetMultiStringArg(2, -1)
		end

		self:BroadcastActionMsg("%caller% ip banned %target%" .. (duration ~= 0 and " for %duration%" or " permanently") .. (reason and " (%reason%)" or ""), {
			target = target,
			duration = duration ~= 0 and BSU.StringTime(duration, 10000) or nil,
			reason = reason
		})

		BSU.IPBanPlayer(target, reason, duration, self:GetCaller())
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
	cmd:SetFunction(function(self)
		local address = BSU.Address(self:GetStringArg(1, true))
		local targetData = BSU.GetPlayerDataByIPAddress(address) -- find any players associated with this address
		for i = 1, #targetData do -- make sure caller is allowed to target all of these players
			self:CheckCanTargetSteamID(targetData[i].steamid, true)
		end

		local duration = self:GetNumberArg(2)
		local reason
		if duration then
			duration = math.max(duration, 0)
			reason = self:GetMultiStringArg(3, -1)
		else
			duration = 0 -- permaban
			reason = self:GetMultiStringArg(2, -1)
		end

		local ply = self:GetCaller()
		BSU.BanIP(address, reason, duration, ply:IsValid() and ply:SteamID64())

		local names = {}
		for i = 1, #targetData do
			table.insert(names, targetData[i].name)
		end

		self:BroadcastActionMsg("%caller% banned an ip" .. (next(names) ~= nil and " (%names%)" or "") .. (duration ~= 0 and " for %duration%" or " permanently") .. (reason and " (%reason%)" or ""), {
			names = next(names) ~= nil and names or nil,
			duration = duration ~= 0 and BSU.StringTime(duration, 10000) or nil,
			reason = reason
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
	cmd:SetFunction(function(self)
		local steamid = self:GetStringArg(1, true)
		steamid = BSU.ID64(steamid)

		local caller = self:GetCaller()
		BSU.RevokeSteamIDBan(steamid, caller:IsValid() and caller:SteamID64()) -- this also checks if the steam id is actually banned

		local name = BSU.GetPlayerDataBySteamID(steamid).name

		self:BroadcastActionMsg("%caller% unbanned %steamid%" .. (name and " (%name%)" or ""), {
			steamid = util.SteamIDFrom64(steamid),
			name = name
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
	cmd:SetFunction(function(self)
		local address = self:GetStringArg(1, true)
		address = BSU.Address(address)

		local caller = self:GetCaller()
		BSU.RevokeIPBan(address, caller:IsValid() and caller:SteamID64()) -- this also checks if the steam id is actually banned

		local targetData, names = BSU.GetPlayerDataByIPAddress(address), {}
		for i = 1, #targetData do -- get all the names of players associated with the address
			table.insert(names, targetData[i].name)
		end

		self:BroadcastActionMsg("%caller% unbanned an ip" .. (next(names) ~= nil and " (%names%)" or ""), {
			names = next(names) ~= nil and names or nil
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
	cmd:SetFunction(function(self)
		local target = self:GetPlayerArg(1, true)
		local ply, silent = self:GetCaller(), self:GetSilent()
		BSU.RunCommand(ply, "ban", self:GetRawMultiStringArg(1, -1), silent)
		local ownerID = target:OwnerSteamID64()
		if ownerID ~= target:SteamID64() then
			BSU.RunCommand(ply, "banid", ownerID .. " " .. (self:GetRawMultiStringArg(2, -1) or ""), silent)
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
	cmd:SetFunction(function(self)
		local ply, argStr, silent = self:GetCaller(), self:GetRawMultiStringArg(1, -1) or "", self:GetSilent()
		BSU.RunCommand(ply, "superban", argStr, silent)
		BSU.RunCommand(ply, "ipban", argStr, silent)
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
	cmd:SetFunction(function(self)
		local target = self:GetPlayerArg(1, true)
		self:CheckCanTarget(target, true)
		local reason = self:GetMultiStringArg(2, -1)

		self:BroadcastActionMsg("%caller% kicked %target%<%steamid%>" .. (reason and " (%reason%)" or ""), {
			target = target,
			steamid = target:SteamID(),
			reason = reason
		})

		BSU.KickPlayer(target, reason, self:GetCaller())
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
	cmd:SetFunction(function(self)
		local target, groupid = self:GetPlayerArg(1, true), string.lower(self:GetStringArg(2, true))

		if not BSU.GetGroupByID(groupid) then error("Group does not exist") end
		if BSU.GetPlayerData(target).groupid == groupid then error("Target is already in that group") end

		self:BroadcastActionMsg("%caller% set the group of %target% to %groupid%", {
			target = target,
			groupid = groupid
		})

		BSU.SetPlayerGroup(target, groupid)
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
	cmd:SetFunction(function(self)
		local target, team = self:GetPlayerArg(1, true), self:GetNumberArg(2)

		local teamData
		if team then
			teamData = BSU.GetTeamByID(team)
		else
			teamData = BSU.GetTeamByName(self:GetMultiStringArg(2, -1, true))
		end

		if not teamData then error("Team does not exist") end
		if BSU.GetPlayerData(target).team == teamData.id then error("Target is already in that team") end

		self:BroadcastActionMsg("%caller% set the team of %target% to %name%", {
			target = target,
			name = teamData.name
		})

		BSU.SetPlayerTeam(target, teamData.id)
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
	cmd:SetFunction(function(self)
		local target = self:GetPlayerArg(1, true)

		self:BroadcastActionMsg("%caller% reset the team of %target%", {
			target = target
		})

		BSU.ResetPlayerTeam(target)
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
	cmd:SetFunction(function(self)
		local groupid, name, value = string.lower(self:GetStringArg(1, true)), self:GetStringArg(2, true), self:GetStringArg(3, true)

		local group = BSU.GetGroupByID(groupid)
		if not group then error("Group does not exist") end
		if group.usergroup == "superadmin" then error("Group is in the 'superadmin' usergroup and thus already has access to everything") end

		local typ = getPrivFromName(name)
		if not typ then error("Unknown privilege type") end

		local priv = BSU.SQLSelectByValues(BSU.SQL_GROUP_PRIVS, { groupid = groupid, type = typ, value = value })[1]
		if priv and priv.granted == 1 then error("Privilege is already granted to this group") end

		BSU.RegisterGroupPrivilege(groupid, typ, value, true)

		self:BroadcastActionMsg("%caller% granted the group %groupid% access to %value% (%name%)", {
			groupid = groupid,
			value = value,
			name = getNameFromPriv(typ)
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
	cmd:SetFunction(function(self)
		local groupid, name, value = string.lower(self:GetStringArg(1, true)), self:GetStringArg(2, true), self:GetStringArg(3, true)

		local group = BSU.GetGroupByID(groupid)
		if not group then error("Group does not exist") end
		if group.usergroup == "superadmin" then error("Group is in the 'superadmin' usergroup and thus cannot be restricted from anything") end

		local typ = getPrivFromName(name)
		if not typ then error("Unknown privilege type") end

		local priv = BSU.SQLSelectByValues(BSU.SQL_GROUP_PRIVS, { groupid = groupid, type = typ, value = value })[1]
		if priv and priv.granted == 0 then error("Privilege is already revoked from this group") end

		BSU.RegisterGroupPrivilege(groupid, typ, value, false)

		self:BroadcastActionMsg("%caller% revoked the group %groupid% access from %value% (%name%)", {
			groupid = groupid,
			value = value,
			name = getNameFromPriv(typ)
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
	cmd:SetFunction(function(self)
		local groupid, name, value = string.lower(self:GetStringArg(1, true)), self:GetStringArg(2, true), self:GetStringArg(3, true)

		local group = BSU.GetGroupByID(groupid)
		if not group then error("Group does not exist") end

		local typ = getPrivFromName(name)
		if not typ then error("Unknown privilege type") end

		local priv = BSU.SQLSelectByValues(BSU.SQL_GROUP_PRIVS, { groupid = groupid, type = typ, value = value })[1]
		if not priv then error("Privilege on this group doesn't exist") end

		BSU.RemoveGroupPrivilege(groupid, typ, value)

		self:BroadcastActionMsg("%caller% cleared a %kind% privilege on the group %groupid% for %value% (%name%)", {
			kind = priv.granted == 1 and "granting" or "revoking",
			groupid = groupid,
			value = value,
			name = getNameFromPriv(typ),
		})
	end)
end)