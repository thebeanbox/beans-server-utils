--[[
	Name: nothing
	Desc: Do nothing to a player
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("nothing", function(cmd)
	cmd:SetDescription("Do nothing to a player")
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }
		self:BroadcastActionMsg("%caller% did nothing to %targets%", { targets = targets })
	end)
end)
