-- lib/client/commands.lua

function BSU.RunCommand(name, argStr, silent)
  local cmd = BSU._cmds[name]
  if not cmd then error("Command '" .. name .. "' does not exist") end

  local handler = BSU.CommandHandler(LocalPlayer(), argStr, silent)

  xpcall(cmd.func, function(err) chat.AddText(LocalPlayer(), BSU.CLR_ERROR, "Command errored with: " .. string.Split(err, ": ")[2]) end, handler, LocalPlayer(), #handler._args, argStr)
end

function BSU.RegisterServerCommand(name, description, category)
  local cmd = BSU.Command(name, description, category)
  cmd.serverside = true
  BSU.RegisterCommand(cmd)
end