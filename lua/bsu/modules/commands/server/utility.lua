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
    local targets = self:GetPlayersArg(1)
    if targets then
      targets = self:FilterTargets(targets, true)
    else
      targets = { ply }
    end
    for _, ply in pairs(targets) do
      ply:GodEnable()
    end
    self:BroadcastActionMsg("%user% godded %param%", { ply, targets })
  end)
end)
BSU.AliasCommand("build", "god")

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
    local targets = self:GetPlayersArg(1)
    if targets then
      targets = self:FilterTargets(targets, true)
    else
      targets = { ply }
    end
    for _, ply in pairs(targets) do
      ply:GodDisable()
    end
    self:BroadcastActionMsg("%user% ungodded %param%", { ply, targets })
  end)
end)
BSU.AliasCommand("pvp", "ungod")

--[[
  Name: teleport
  Desc: Teleports player A to player B or you to player A if there is not player B
  Arguments:
    1. Targets A (players)
    2. Targets B (players)
]]
BSU.SetupCommand("teleport", function(cmd)
  cmd:SetDescription("Teleports player A to player B or you to player A if there is not player B")
  cmd:SetCategory("utility")
  cmd:SetAccess(BSU.CMD_ADMIN)
  cmd:SetFunction(function(self, ply)
    local targetA, targetB

    targetA = self:GetPlayerArg(1)
    if targetA then
      self:CheckCanTarget(targetA, true)

      targetB = self:GetPlayerArg(2, true)
      if targetA == targetB then error("Cannot teleport target to the same target") end
      self:CheckCanTarget(targetB, true)

      targetA:SetPos(targetB:GetPos())
    else
      targetA = self:GetPlayersArg(1, true)

      targetB = self:GetPlayerArg(2, true)
      self:CheckCanTarget(targetB, true)

      for i = 1, #targetA do -- remove targetB from list of targets
        local tar = targetA[i]
        if tar == targetB then
          table.remove(targetA, i)
          break
        end
      end

      targetA = self:FilterTargets(targetA, true)

      local pos = targetB:GetPos()
      for i = 1, #targetA do
        local tar = targetA[i]
        tar:SetPos(pos)
      end
    end

    self:BroadcastActionMsg("%user% teleported %param% to %param%", { ply, targetA, targetB })
  end)
end)
BSU.AliasCommand("tp", "teleport")