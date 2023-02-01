--[[
	Name: nothing
	Desc: Do nothing to a player
	Arguments:
		1. Targets (players)
]]
BSU.SetupCommand("nothing", function(cmd)
	cmd:SetDescription("Do nothing to a player")
	cmd:SetFunction(function(self, ply)
		local targets = self:FilterTargets(self:GetPlayersArg(1, true), true)
		self:BroadcastActionMsg("%user% did nothing to %param%", { ply, targets })
	end)
end)