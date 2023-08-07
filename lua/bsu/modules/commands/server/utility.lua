local function teleportPlayer(ply, pos)
	ply.bsu_oldPos = ply:GetPos() -- used for return cmd
	ply:SetPos(pos)
end

--[[
	Name: send
	Desc: Teleport players to a target player
	Arguments:
		1. Targets (players)
		2. Target (player)
]]
BSU.SetupCommand("send", function(cmd)
	cmd:SetDescription("Teleports players to a target player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets, target)
		local teleported = {}

		local pos = target:GetPos()
		for _, v in ipairs(targets) do
			teleportPlayer(v, pos)
			table.insert(teleported, v)
		end

		if next(teleported) ~= nil then
			self:BroadcastActionMsg("%caller% sent %teleported% to %target%", { teleported = teleported, target = target })
		end
	end)
	cmd:AddPlayersArg("targets", { filter = true })
	cmd:AddPlayerArg("target", { check = true })
end)

--[[
	Name: teleport
	Desc: Teleport yourself to your aim position
	Arguments:
]]
BSU.SetupCommand("teleport", function(cmd)
	cmd:SetDescription("Teleport yourself to your aim position")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, caller)
		if self:CheckExclusive(caller, true) then
			local aimPos = caller:GetEyeTrace().HitPos
			teleportPlayer(caller, aimPos)
		end
	end)
	cmd:SetValidCaller(true)
end)
BSU.AliasCommand("tp", "teleport")

--[[
	Name: goto
	Desc: Teleport yourself to a player
	Arguments:
		1. Target (player)
]]
BSU.SetupCommand("goto", function(cmd)
	cmd:SetDescription("Teleports yourself to a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, caller, target)
		if self:CheckExclusive(caller, true) then
			teleportPlayer(caller, target:GetPos())
			self:BroadcastActionMsg("%caller% teleported to %target%", { target = target })
		end
	end)
	cmd:SetValidCaller(true)
	cmd:AddPlayerArg("target", { check = true })
end)

--[[
	Name: bring
	Desc: Teleport players to yourself
	Arguments:
		1. Targets (players)
]]
BSU.SetupCommand("bring", function(cmd)
	cmd:SetDescription("Teleports yourself to a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, caller, targets)
		local teleported = {}

		local pos = caller:GetPos()
		for _, v in ipairs(targets) do
			if  v ~= self:GetCaller() and self:CheckExclusive(v, true) then
				teleportPlayer(v, pos)
				table.insert(teleported, v)
			end
		end

		if next(teleported) ~= nil then
			self:BroadcastActionMsg("%caller% brought %teleported%", { teleported = teleported })
		end
	end)
	cmd:SetValidCaller(true)
	cmd:AddPlayersArg("targets", { filter = true })
end)

--[[
	Name: return
	Desc: Return players to their original position
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("return", function(cmd)
	cmd:SetDescription("Return a player or multiple players to their original position")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local returned = {}

		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) and v.bsu_oldPos then
				v:SetPos(v.bsu_oldPos)
				v.bsu_oldPos = nil
				table.insert(returned, v)
			end
		end

		if next(returned) ~= nil then
			self:BroadcastActionMsg("%caller% returned %returned%", { returned = returned })
		end
	end)
	cmd:AddPlayersArg("targets", { filter = true })
end)

--[[
	Name: nolag
	Desc: Freeze all entities on the map
	Arguments:
]]
BSU.SetupCommand("nolag", function(cmd)
	cmd:SetDescription("Freeze all entities on the map")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		for _, ent in ipairs(ents.GetAll()) do
			for i = 0, ent:GetPhysicsObjectCount() - 1 do
				local physObj = ent:GetPhysicsObjectNum(i)
				if IsValid(physObj) then
					physObj:EnableMotion(false)
				end
			end
		end

		self:BroadcastActionMsg("%caller% froze all props")
	end)
end)

--[[
	Name: cleardecals
	Desc: Clear all decals
	Arguments:
]]
BSU.SetupCommand("cleardecals", function(cmd)
	cmd:SetDescription("Clear all decals")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		for _, ply in pairs(player.GetHumans()) do
			ply:ConCommand("r_cleardecals")
		end

		self:BroadcastActionMsg("%caller% cleared decals")
	end)
end)

--[[
	Name: removeragdolls
	Desc: Remove all clientside ragdolls
	Arguments:
]]
BSU.SetupCommand("removeragdolls", function(cmd)
	cmd:SetDescription("Remove all clientside ragdolls")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		BSU.ClientRPC(nil, "game.RemoveRagdolls")

		self:BroadcastActionMsg("%caller% removed ragdolls")
	end)
end)

--[[
	Name: stopsound
	Desc: Stop sounds globally
	Arguments:
]]
BSU.SetupCommand("stopsound", function(cmd)
	cmd:SetDescription("Stop sounds globally")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		for _, ply in ipairs(player.GetHumans()) do
			ply:ConCommand("stopsound;stopsoundscape")
		end

		self:BroadcastActionMsg("%caller% stopped all sounds")
	end)
end)

--[[
	Name: playsound
	Desc: Play a sound globally
	Arguments:
		1. Sound Path (string)
]]
BSU.SetupCommand("playsound", function(cmd)
	cmd:SetDescription("Play a sound globally")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, path)
		BSU.ClientRPC(nil, "surface.PlaySound", path)
		self:BroadcastActionMsg("%caller% played sound %path%", { path = path })
	end)
	cmd:AddStringArg("sound path")
end)

--[[
	Name: asay
	Desc: Send a message to admins
	Arguments:
		1. Message (string)
]]
BSU.SetupCommand("asay", function(cmd)
	cmd:SetDescription("Send a message to admins")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ANYONE)
	cmd:SetSilent(true)
	cmd:SetFunction(function(self, caller, msg)
		for _, v in ipairs(player.GetHumans()) do
			if v ~= caller then
				local check = BSU.CheckPlayerPrivilege(v:SteamID(), BSU.PRIV_MISC, "bsu_see_asay")
				-- don't show message if privilege is set revoked, or there is no privilege set and they are not an admin
				if check == false or check == nil and not v:IsAdmin() then continue end
			end
			self:SendFormattedMsg(v, "%caller% to admins: %msg%", { msg = msg })
		end

		self:SendFormattedMsg(NULL, "%caller% to admins: %msg%", { msg = msg }) -- also send to server console
	end)
	cmd:AddStringArg("message", { multi = true })
end)

--[[
	Name: psay
	Desc: Send a private message to a player
	Arguments:
		1. Name (string)
		2. Message (string)
]]
BSU.SetupCommand("psay", function(cmd)
	cmd:SetDescription("Send a private message to a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ANYONE)
	cmd:SetSilent(true)
	cmd:SetFunction(function(self, caller, target, msg)
		if target == caller then error("Unable to message yourself") end
		self:SendFormattedMsg({ caller, target }, "%caller% to %target%: %msg%", { target = target, msg = msg })
	end)
	cmd:AddPlayerArg("target")
	cmd:AddStringArg("message", { multi = true })
end)
BSU.AliasCommand("p", "psay")

--[[
	Name: tsay
	Desc: Send a message to the textbox
	Arguments:
		1. Message (string)
]]
BSU.SetupCommand("tsay", function(cmd)
	cmd:SetDescription("Send a message to the textbox")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(_, _, msg)
		BSU.SendChatMsg(nil, msg)
	end)
	cmd:AddStringArg("message", { multi = true })
end)

--[[
	Name: csay
	Desc: Send a message to the center of everyone's screen
	Arguments:
		1. Message (string)
]]
BSU.SetupCommand("csay", function(cmd)
	cmd:SetDescription("Send a message to the center of everyone's screen")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(_, _, msg)
		PrintMessage(HUD_PRINTCENTER, msg)
	end)
	cmd:AddStringArg("message", { multi = true })
end)

hook.Add("PlayerSay", "BSU_CommandShorthand", function(ply, text)
	if string.sub(text, 1, 3) == "@@@" then
		BSU.SafeRunCommand(ply, "csay", string.sub(text, 4))
		return ""
	elseif string.sub(text, 1, 2) == "@@" then
		BSU.SafeRunCommand(ply, "tsay", string.sub(text, 3))
		return ""
	elseif string.sub(text, 1, 1) == "@" then
		BSU.SafeRunCommand(ply, "asay", string.sub(text, 2))
		return ""
	end
end)

--[[
	Name: afk
	Desc: Mark yourself as afk
	Arguments:
		1. Reason (string)
]]
BSU.SetupCommand("afk", function(cmd)
	cmd:SetDescription("Mark yourself as afk")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ANYONE)
	cmd:SetSilent(true)
	cmd:SetFunction(function(_, caller, reason)
		caller.bsu_afk = true
		local msg = { caller, " is now AFK" }
		if reason then table.Add(msg, { " (", BSU.CLR_PARAM, reason, BSU.CLR_TEXT, ")" }) end
		BSU.SendChatMsg(nil, unpack(msg))
	end)
	cmd:SetValidCaller(true)
	cmd:AddStringArg("reason", { optional = true, multi = true })
end)

-- prevent gaining total time while afk
hook.Add("BSU_PlayerTotalTime", "BSU_PreventAFKTime", function(ply)
	if ply.bsu_afk then return false end
end)

-- make not afk if any key presses
hook.Add("KeyPress", "BSU_ClearAFK", function(ply)
	if ply.bsu_afk then
		ply.bsu_afk = nil
		BSU.SendChatMsg(nil, ply, " is no longer AFK")
	end
	ply.bsu_last_interacted_time = SysTime()
end)

-- make afk after some time with no key presses
timer.Create("BSU_CheckAFK", 1, 0, function()
	for _, ply in ipairs(player.GetHumans()) do
		if not ply.bsu_last_interacted_time or ply.bsu_afk then continue end
		if SysTime() > ply.bsu_last_interacted_time + 600 then
			BSU.SafeRunCommand(ply, "afk")
		end
	end
end)