-- base/server/commands.lua

-- allow command usage in chat
hook.Add("PlayerSay", "BSU_RunChatCommand", function(ply, text)
  if not string.StartWith(text, BSU.CMD_PREFIX) then return end

  local split = string.Split(text, " ")
  local name = string.lower(string.sub(table.remove(split, 1), 2))
  local argStr = table.concat(split, " ")

  if BSU.GetCommandByName(name) then
    BSU.SafeRunCommand(name, ply, argStr)
  end
end)