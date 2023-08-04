local function teleportPlayer(ply, pos)
	ply.bsu_oldPos = ply:GetPos() -- used for return cmd
	ply:SetPos(pos)
end

--[[
	Name: teleport
	Desc: Teleport players to a target player
	Arguments:
		1. Targets (players)
		2. Target (player)
]]
BSU.SetupCommand("teleport", function(cmd)
	cmd:SetDescription("Teleports players to a target player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targetA, targetB

		local teleported = {}

		targetA = self:GetPlayerArg(1)
		if targetA then
			self:CheckCanTarget(targetA, true)

			targetB = self:GetPlayerArg(2, true)
			if targetA == targetB then error("Cannot teleport target to same target") end
			self:CheckCanTarget(targetB, true)

			if self:CheckExclusive(targetA, true) then
				teleportPlayer(targetA, targetB:GetPos())
				table.insert(teleported, targetA)
			end
		else
			targetA = self:FilterTargets(self:GetPlayersArg(1, true), true, true)

			targetB = self:GetPlayerArg(2, true)
			self:CheckCanTarget(targetB, true)

			local pos = targetB:GetPos()
			for _, v in ipairs(targetA) do
				if self:CheckExclusive(v, true) then
					teleportPlayer(v, pos)
					table.insert(teleported, v)
				end
			end
		end

		if next(teleported) ~= nil then
			self:BroadcastActionMsg("%caller% teleported %teleported% to %target%", { teleported = teleported, target = targetB })
		end
	end)
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
	cmd:SetFunction(function(self)
		local target = self:GetPlayerArg(1, true)
		self:CheckCanTarget(target, true)

		local ply = self:GetCaller(true)
		if self:CheckExclusive(ply, true) then
			teleportPlayer(ply, target:GetPos())
			self:BroadcastActionMsg("%caller% teleported to %target%", { target = target })
		end
	end)
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
	cmd:SetFunction(function(self)
		local targets = self:FilterTargets(self:GetPlayersArg(1, true), true, true)

		local pos = self:GetCaller(true):GetPos()
		local teleported = {}
		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) then
				teleportPlayer(v, pos)
				table.insert(teleported, v)
			end
		end

		if next(teleported) ~= nil then
			self:BroadcastActionMsg("%caller% brought %teleported%", { teleported = teleported })
		end
	end)
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
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), nil, true) or { self:GetCaller(true) }

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
end)

--[[
	Name: nolag
	Desc: Freeze all entities (usually in the event of extreme lag)
	Arguments:
]]
BSU.SetupCommand("nolag", function(cmd)
	cmd:SetDescription("Freeze all entities (usually in the event of extreme lag)")
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
	Desc: Clears all decals
	Arguments:
]]
BSU.SetupCommand("cleardecals", function(cmd)
	cmd:SetDescription("Clears all decals")
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
	cmd:SetFunction(function(self)
		local path = self:GetStringArg(1, true)
		BSU.ClientRPC(nil, "surface.PlaySound", path)

		self:BroadcastActionMsg("%caller% cleared decals")
	end)
end)
