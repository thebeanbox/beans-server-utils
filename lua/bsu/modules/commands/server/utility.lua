local function teleportPlayer(ply, pos)
	ply.bsu_oldPos = ply:GetPos() -- used for return cmd
	ply:SetPos(pos)
end

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

BSU.SetupCommand("removeragdolls", function(cmd)
	cmd:SetDescription("Remove all clientside ragdolls")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		BSU.ClientRPC(nil, "game.RemoveRagdolls")

		self:BroadcastActionMsg("%caller% removed ragdolls")
	end)
end)

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

BSU.SetupCommand("spectate", function(cmd)
	cmd:SetDescription("Be one with a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(self, caller, target)
		getSpawnInfo(target)

		caller.bsu_spectating = true
		caller:SetColor(Color(0, 0, 0, 0))
		caller:Spectate(OBS_MODE_IN_EYE)
		caller:SpectateEntity(target)
		caller:StripWeapons()

		self:PrintChatMsg("Spectating ", target)
	end)
	cmd:SetValidCaller(true)
	cmd:AddPlayerArg("target", { check = true })
end)

BSU.SetupCommand("unspectate", function(cmd)
	cmd:SetDescription("Unspectate a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(self, caller)
		if caller.bsu_spectating then
			caller.bsu_spectating = nil
			caller:UnSpectate()
			doSpawn(caller)
			caller:SetColor(Color(255, 255, 255, 255))
		end

		self:PrintChatMsg("Stopped spectating")
	end)
	cmd:SetValidCaller(true)
end)

hook.Add("KeyPress", "BSU_StopSpectating", function(ply)
	if ply.bsu_spectating then
		BSU.SafeRunCommand(ply, "unspectate")
	end
end)

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

util.AddNetworkString("bsu_menu_open")
util.AddNetworkString("bsu_menu_regen")

BSU.SetupCommand("menu", function(cmd)
	cmd:SetDescription("Opens the menu")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ANYONE)
	cmd:SetFunction(function(self, caller)
		net.Start("bsu_menu_open")
		net.Send(caller)
	end)
end)

BSU.SetupCommand("menuregen", function(cmd)
	cmd:SetDescription("Regenerates the menu")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ANYONE)
	cmd:SetFunction(function(self, caller)
		net.Start("bsu_menu_regen")
		net.Send(caller)
	end)
end)