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
	cmd:SetFunction(function(self, ply)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		for _, v in ipairs(targets) do
			v:GodEnable()
		end

		self:BroadcastActionMsg("%user% godded %param%", { ply, targets })
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
	cmd:SetFunction(function(self, ply)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		for _, v in ipairs(targets) do
			v:GodDisable()
		end

		self:BroadcastActionMsg("%user% ungodded %param%", { ply, targets })
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
	cmd:SetFunction(function(self, ply)
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
			for _, tar in ipairs(targetA) do
				teleport(tar, pos)
			end
		end

		self:BroadcastActionMsg("%user% teleported %param% to %param%", { ply, targetA, targetB })
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
	cmd:SetFunction(function(self, ply)
		local target = self:GetPlayerArg(1, true)
		self:CheckCanTarget(target, true)

		teleport(self:GetCaller(true), target:GetPos())

		self:BroadcastActionMsg("%user% teleported to %param%", { ply, target })
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
	cmd:SetFunction(function(self, ply)
		local targets = self:FilterTargets(self:GetPlayersArg(1, true), true, true)

		local pos = ply:GetPos()
		for _, tar in ipairs(targets) do
			teleport(tar, pos)
		end

		self:BroadcastActionMsg("%user% brought %param%", { ply, targets })
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
	cmd:SetFunction(function(self, ply)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		local newTargets = {}
		for _, tar in ipairs(targets) do
			if tar.bsu_oldPos then
				table.insert(newTargets, tar)
			end
		end

		if table.IsEmpty(newTargets) then error("Failed to return any players") end

		for _, tar in ipairs(newTargets) do
			tar:SetPos(tar.bsu_oldPos)
			tar.bsu_oldPos = nil
		end

		self:BroadcastActionMsg("%user% returned %param%", { ply, newTargets })
	end)
end)
