--[[
	Name: god
	Desc: Enable godmode on players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("god", function(cmd)
	cmd:SetDescription("Enables godmode on a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		for _, v in ipairs(targets) do
			v:GodEnable()
		end

		self:BroadcastActionMsg("%caller% godded %targets%", { targets = targets })
	end)
end)
BSU.AliasCommand("build", "god")

--[[
	Name: ungod
	Desc: Disable godmode on players
	Arguments:
		1. Targets (players)
]]
BSU.SetupCommand("ungod", function(cmd)
	cmd:SetDescription("Enables godmode on a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		for _, v in ipairs(targets) do
			v:GodDisable()
		end

		self:BroadcastActionMsg("%caller% ungodded %targets%", { targets = targets })
	end)
end)
BSU.AliasCommand("pvp", "ungod")

local function teleport(ply, pos)
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

		targetA = self:GetPlayerArg(1)
		if targetA then
			self:CheckCanTarget(targetA, true)

			targetB = self:GetPlayerArg(2, true)
			if targetA == targetB then error("Cannot teleport target to same target") end
			self:CheckCanTarget(targetB, true)

			teleport(targetA, targetB:GetPos())
		else
			targetA = self:FilterTargets(self:GetPlayersArg(1, true), true, true)

			targetB = self:GetPlayerArg(2, true)
			self:CheckCanTarget(targetB, true)

			local pos = targetB:GetPos()
			for _, v in ipairs(targetA) do
				teleport(v, pos)
			end
		end

		self:BroadcastActionMsg("%caller% teleported %targetA% to %targetB%", { targetA = targetA, targetB = targetB })
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

		teleport(self:GetCaller(true), target:GetPos())

		self:BroadcastActionMsg("%caller% teleported to %target%", { target = target })
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
		for _, v in ipairs(targets) do
			teleport(v, pos)
		end

		self:BroadcastActionMsg("%caller% brought %targets%", { targets = targets })
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
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		local returned = {}
		for _, v in ipairs(targets) do
			if v.bsu_oldPos then
				v:SetPos(v.bsu_oldPos)
				v.bsu_oldPos = nil
				table.insert(returned, v)
			end
		end

		if next(returned) == nil then error("Failed to return any players") end

		self:BroadcastActionMsg("%caller% returned %returned%", { returned = returned })
	end)
end)
