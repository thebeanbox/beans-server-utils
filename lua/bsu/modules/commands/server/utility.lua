local function teleportPlayer(ply, pos)
	ply.bsu_oldPos = ply:GetPos() -- used for return cmd
	ply:SetPos(pos)
end

BSU.SetupCommand("send", function(cmd)
	cmd:SetDescription("Teleport players to a target player")
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
	cmd:SetDescription("Teleport yourself to a player")
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
	cmd:SetDescription("Teleport yourself to a player")
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

BSU.SetupCommand("cleanup", function(cmd)
	cmd:SetDescription("Cleanup all props that are owned by a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, target)
		local weps = {}
		for _, v in ipairs(target:GetWeapons()) do
			weps[v] = true
		end

		for _, v in ipairs(BSU.GetOwnerEntities(target:SteamID64())) do
			if not weps[v] then -- don't strip their weapons
				v:Remove()
			end
		end

		self:BroadcastActionMsg("%caller% cleaned up %target%'s props", { target = target })
	end)
	cmd:AddPlayerArg("target", { check = true })
end)

local debrisGroups = {
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_INTERACTIVE_DEBRIS] = true,
	[COLLISION_GROUP_INTERACTIVE] = true
}

BSU.SetupCommand("cleanupdebris", function(cmd)
	cmd:SetDescription("Cleanup all props that are considered debris")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		for _, v in ipairs(ents.GetAll()) do
			-- remove all entities that are debris and ownerless or world-owned
			if debrisGroups[v:GetCollisionGroup()] then
				-- BSU.GetOwner returns nil if the entity is ownerless
				local owner = BSU.GetOwner(v)
				if not owner or owner:IsWorld() then
					v:Remove()
				end
			end
		end

		self:BroadcastActionMsg("%caller% cleaned up debris")
	end)
end)

BSU.SetupCommand("cleanupdisconnected", function(cmd)
	cmd:SetDescription("Cleanup all props that are owned by disconnected players")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		for _, v in ipairs(ents.GetAll()) do
			-- BSU.GetOwner returns NULL if the player owner disconnected
			-- (do not use IsValid or IsPlayer here otherwise world-owned entities will get removed too)
			if BSU.GetOwner(v) == NULL then
				v:Remove()
			end
		end

		self:BroadcastActionMsg("%caller% cleaned up disconnected")
	end)
end)

BSU.SetupCommand("cleardecals", function(cmd)
	cmd:SetDescription("Clear all clientside decals")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		for _, ply in ipairs(player.GetHumans()) do
			ply:ConCommand("r_cleardecals")
		end

		self:BroadcastActionMsg("%caller% cleared clientside decals")
	end)
end)

BSU.SetupCommand("cleargibs", function(cmd)
	cmd:SetDescription("Clear all clientside gibs")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		BSU.RemoveClientProps()

		self:BroadcastActionMsg("%caller% cleared clientside gibs")
	end)
end)

BSU.SetupCommand("clearragdolls", function(cmd)
	cmd:SetDescription("Clear all clientside ragdolls")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		BSU.RemoveClientRagdolls()

		self:BroadcastActionMsg("%caller% cleared clientside ragdolls")
	end)
end)

BSU.SetupCommand("cleareffects", function(cmd)
	cmd:SetDescription("Clear all clientside effects")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		BSU.RemoveClientEffects()

		self:BroadcastActionMsg("%caller% cleared clientside effects")
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
		caller.bsu_spectating = true

		caller.bsu_spawninfo = BSU.GetSpawnInfo(caller)

		caller:SetColor(Color(0, 0, 0, 0))
		caller:Spectate(OBS_MODE_IN_EYE)
		caller:SpectateEntity(target)
		caller:StripWeapons()

		self:PrintChatMsg("Now spectating ", target)
	end)
	cmd:SetValidCaller(true)
	cmd:AddPlayerArg("target", { check = true })
end)

BSU.SetupCommand("unspectate", function(cmd)
	cmd:SetDescription("Unspectate a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(_, caller)
		if not caller.bsu_spectating then return end

		caller.bsu_spectating = nil
		caller:UnSpectate()
		caller:SetColor(Color(255, 255, 255, 255))

		BSU.SpawnWithInfo(caller, caller.bsu_spawninfo)
		caller.bsu_spawninfo = nil
	end)
	cmd:SetValidCaller(true)
end)

hook.Add("KeyPress", "BSU_StopSpectating", function(ply)
	if ply.bsu_spectating then
		BSU.SafeRunCommand(ply, "unspectate")
	end
end)

BSU.SetupCommand("give", function(cmd)
	cmd:SetDescription("Spawns entity at a target")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets, classname)
		for _, v in ipairs(targets) do
			v:Give(classname)
		end

		if next(targets) ~= nil then
			  self:BroadcastActionMsg("%caller% gave %targets% %classname%", { classname = classname, targets = targets })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
	cmd:AddStringArg("classname")
end)


BSU.SetupCommand("hide", function(cmd)
	cmd:SetDescription("Hides yourself")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(self, caller)
		caller.bsu_hidden = true
		caller:SetNoDraw(true)

		hook.Run("BSU_Hidden", caller, true)

		self:BroadcastActionMsg("%caller% hid themself")
	end)
end)
BSU.AliasCommand("cloak", "hide")

BSU.SetupCommand("unhide", function(cmd)
	cmd:SetDescription("Unhides yourself")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(self, caller)
		if not caller.bsu_hidden then return end
		caller.bsu_hidden = nil
		caller:SetNoDraw(false)

		hook.Run("BSU_Hidden", caller, false)

		self:BroadcastActionMsg("%caller% unhid themself")
	end)
end)
BSU.AliasCommand("uncloak", "unhide")

BSU.SetupCommand("asay", function(cmd)
	cmd:SetDescription("Send a message to admins")
	cmd:SetCategory("utility")
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
	cmd:SetDescription("Open the menu")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ANYONE)
	cmd:SetFunction(function(_, caller)
		net.Start("bsu_menu_open")
		net.Send(caller)
	end)
	cmd:SetValidCaller(true)
end)

BSU.SetupCommand("menuregen", function(cmd)
	cmd:SetDescription("Regenerate the menu")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ANYONE)
	cmd:SetFunction(function(_, caller)
		net.Start("bsu_menu_regen")
		net.Send(caller)
	end)
	cmd:SetValidCaller(true)
end)

BSU.SetupCommand("vote", function(cmd)
	cmd:SetDescription("Start a vote")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, caller, title, ...)
		if BSU.HasActiveVote(caller) then
			error("You already have a vote active!")
		end

		BSU.StartVote(title, 30, caller, { ... }, function(winner)
			if not winner then
				BSU.SendChatMsg(nil, BSU.CLR_TEXT, "No one voted! (", BSU.CLR_PARAM, title, BSU.CLR_TEXT, ")")
				return
			end

			BSU.SendChatMsg(nil, BSU.CLR_TEXT, "'", BSU.CLR_PARAM, winner, BSU.CLR_TEXT, "' won the vote! (", BSU.CLR_PARAM, title, BSU.CLR_TEXT, ")")
		end)

		self:BroadcastActionMsg("%caller% started a vote! (%title%)", { title = title })
	end)
	cmd:AddStringArg("title")
	cmd:AddStringArg("option1")
	cmd:AddStringArg("option2")
	for i = 3, 10 do
		cmd:AddStringArg("option" .. i, { optional = true })
	end
end)

local maps = file.Find("maps/*.bsp", "GAME")

-- Trim file ending
local votemapOptions = {}
local mapOptions = {}
local mapLookup = {}
for i, map in ipairs(maps) do
	local mapname = string.sub(map, 1, #map - 4)
	votemapOptions[i] = mapname
	mapOptions[i] = mapname
	mapLookup[mapname] = true
end
table.insert(votemapOptions, 1, "Stay Here")

BSU.SetupCommand("votemap", function(cmd)
	cmd:SetDescription("Start a vote to change the map")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(_, caller)
		BSU.StartVote("Map Vote", 60, caller, votemapOptions, function(winner)
			if not winner then return end
			if winner == "Stay Here" then
				BSU.SendChatMsg(nil, BSU.CLR_TEXT, "Map will not change.")
				return
			end

			BSU.SendChatMsg(nil, BSU.CLR_TEXT, "The map will change to '", BSU.CLR_PARAM, winner, BSU.CLR_TEXT, "' in 60 seconds, please save your stuff immediately.")
			timer.Simple(60, function()
				RunConsoleCommand("changelevel", winner)
			end)
		end)
	end)
end)

BSU.SetupCommand("changemap", function(cmd)
	cmd:SetDescription("Change the map")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(_, _, map)
		if not mapLookup[map] then
			error(string.format("'%s' is not a valid map.", map))
		end

		RunConsoleCommand("changelevel", map)
	end)
	cmd:AddStringArg("map", { autocomplete = mapOptions })
end)

BSU.SetupCommand("maplist", function(cmd)
	cmd:SetDescription("List all maps available on the server")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(self)
		local msg = {color_white, "\n\n[Maps Available On The Server]\n\n"}
		for mapname, _ in pairs(mapLookup) do
			table.insert(msg, "\n\t- " .. mapname)
		end
		self:PrintConsoleMsg(unpack(msg))
	end)
end)
