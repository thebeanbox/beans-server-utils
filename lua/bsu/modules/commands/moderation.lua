-- commands/moderation.lua

BSU:RegisterCommand({
  name = "freeze",
  aliases = {},
  description = "Freezes the target(s)",
  category = "player",
  args = {
      {
          allowed = { "player" },
          default = "sender"
      }
  },
  hasPermission = function(sender)
      return BSU:PlayerIsStaff(sender)
  end,
  exec = function(sender, args)
      local targets = BSU:GetPlayersByString(args[1]) or { sender }
      for _, ply in ipairs(targets) do
        if ply:HasGodMode() then ply.preFreezeGodMode = true end
        ply:Lock()
      end
      BSU:SendCommandMsg(sender, " froze ", targets})
  end
})

BSU:RegisterCommand({
  name = "unfreeze",
  aliases = {},
  description = "Unfreezes the target(s)",
  category = "player",
  args = {
      {
          allowed = { "player" },
          default = "sender"
      }
  },
  hasPermission = function(sender)
      return BSU:PlayerIsStaff(sender)
  end,
  exec = function(sender, args)
      local targets = BSU:GetPlayersByString(args[1]) or { sender }
      if #targets <= 0 then return end
      for _, ply in ipairs(targets) do
        if ply:HasGodMode() then ply.preFreezeGodMode = false end
        ply:UnLock()
      end
      BSU:SendCommandMsg(sender, " froze ", targets})
  end
})

BSU:RegisterCommand({
  name = "goto",
  aliases = {},
  description = "Teleport to a target",
  category = "player",
  args = {
    {
      allowed = { "player" },
      default = "sender"
    }
  },
  hasPermission = function(sender)
    return BSU:PlayerIsStaff(sender)
  end,
  exec = function(sender, args)
    -- 1 target because teleporting to multiple players doesnt make sense
    local target = BSU:GetPlayersByString(args[1])
    if #target <= 0 then return end
    target = target[1]
    sender:SetPos(target:GetPos())
    BSU:SendCommandMsg(sender, " teleported to ", target})
  end
})