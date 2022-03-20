-- base/server/commands.lua

-- create the concommand
concommand.Add("bsu", function(ply, _, args, argStr)
  if not args[1] then return end
  local name = string.lower(args[1])
  local cmd = BSU.GetCommandByName(name)
  if not cmd then return BSU.SendConMsg(ply, color_white, "Unknown BSU command: " .. name) end

  -- execute the command
  BSU.RunCommand(name, ply, string.sub(argStr, #name + 2))
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE)

-- allow command usage in chat
hook.Add("PlayerSay", "BSU_RunChatCommand", function(ply, text)
  if not string.StartWith(text, BSU.CMD_PREFIX) then return end

  local split = string.Split(text, " ")
  local name = string.lower(string.sub(table.remove(split, 1), 2))
  local argStr = table.concat(split, " ")

  if BSU.GetCommandByName(name) then
    BSU.RunCommand(name, ply, argStr)
  end
end)