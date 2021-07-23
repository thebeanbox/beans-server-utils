-- commands/moderation.lua

/*BSU:RegisterCommand({
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
      local target = args[1]
      if IsValid(target) and not target:IsFlagSet(FL_FROZEN) then
          if target:HasGodMode() then ply.preFreezeGodMode = true end
          
          target:Lock()
          BSU:SendCommandMsg(sender, " froze ", targets})
      end
  end
})