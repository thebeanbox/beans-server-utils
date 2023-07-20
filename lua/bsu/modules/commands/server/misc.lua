--[[
	Name: nothing
	Desc: Do nothing to a player
	Arguments:
		1. Targets (players)
]]
BSU.SetupCommand("nothing", function(cmd)
	cmd:SetDescription("Do nothing to a player")
	cmd:SetFunction(function(self)
		local targets = self:FilterTargets(self:GetPlayersArg(1, true), nil, true)
		self:BroadcastActionMsg("%caller% did nothing to %targets%", { targets = targets })
	end)
end)