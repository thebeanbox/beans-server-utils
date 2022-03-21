--[[
  Name: nothing
  Desc: Do nothing to a player
  Arguments:
    1. Targets (players)
]]
BSU.CreateCommand("nothing", "Do nothing to a player", nil, function(self, ply)
  local targets = self:FilterTargets(self:GetPlayers(1, true), true)
  self:BroadcastActionMsg("%user% did nothing to %param%", {
    ply,
    targets
  })
end)