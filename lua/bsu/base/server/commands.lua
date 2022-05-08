-- base/server/commands.lua

-- create the concommand
local function concommandCallback(ply, _, args, argStr)
  if not args[1] then return end
  local name = string.lower(args[1])
  if not BSU.GetCommandByName(name) then return BSU.SendConMsg(ply, color_white, "Unknown BSU command: '" .. name .. "'") end
  BSU.RunCommand(name, ply, string.sub(argStr, #name + 2))
end

concommand.Add("bsu", concommandCallback)
concommand.Add("_bsu", concommandCallback, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE)

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