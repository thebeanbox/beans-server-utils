--[[
  Name: god
  Desc: Enables godmode on a player
  Arguments:
    1. Targets (players)
]]
BSU.SetupCommand("god", function(cmd)
  cmd:SetDescription("Enables godmode on a player")
  cmd:SetCategory("utility")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local targets = self:GetPlayersArg(1, false) or {ply}
    targets = self:FilterTargets(targets)
    for _, ply in pairs(targets) do
      ply:GodEnable()
    end
    self:BroadcastActionMsg("%user% godded %param%", { ply, targets })
  end)
end)

--[[
  Name: ungod
  Desc: Disables godmode on a player
  Arguments:
    1. Targets (players)
]]
BSU.SetupCommand("ungod", function(cmd)
  cmd:SetDescription("Enables godmode on a player")
  cmd:SetCategory("utility")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local targets = self:GetPlayersArg(1, false) or {ply}
    targets = self:FilterTargets(targets)
    for _, ply in pairs(targets) do
      ply:GodDisable()
    end
    self:BroadcastActionMsg("%user% ungodded %param%", { ply, targets })
  end)
end)

--[[
  Name: teleport
  Desc: Teleports player a to player b or you to player a if there is not player b
  Arguments:
    1. Target A (player)
    2. Target B (player)
]]
BSU.SetupCommand("teleport", function(cmd)
  cmd:SetDescription("Teleports player a to player b or you to player a if there is not player b")
  cmd:SetCategory("utility")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local targetA = self:GetPlayerArg(1, true)
    self:CheckCanTarget(targetA, true)

    local targetB = self:GetPlayerArg(2, false)
    if targetB then
      self:CheckCanTarget(targetB, true)

      targetA:SetPos(targetB:GetPos())
      self:BroadcastActionMsg("%user% teleported %param% to %param%", { ply, targetA, targetB })
    else
      ply:SetPos(targetA:GetPos())
      self:BroadcastActionMsg("%user% teleported to %param%", { ply, targetA })
    end
  end)
end)