-- commands.lua by Bonyoze

bsuCommands = bsuCommands or {}
  
function BSU:RegisterCommand(data)
  if not data.category then
    data.category = "miscellaneous"
  end
  local category = data.category
  data.category = nil -- we no longer need this value
  
  if not bsuCommands[category] then bsuCommands[category] = {} end

  if CLIENT then data.exec = nil end -- the client won't be needing this
  
  table.insert(bsuCommands[category], data)
end

-- load commands
include(MODULES_DIR .. "commands/player.lua")
include(MODULES_DIR .. "commands/chat.lua")

if SERVER then
  -- send commands to clientside
  AddCSLuaFile(MODULES_DIR .. "commands/player.lua")
  AddCSLuaFile(MODULES_DIR .. "commands/chat.lua")

  util.AddNetworkString("BSU_RunCommand")

  function BSU:GetCommandByName(name)
    for category, commands in pairs(bsuCommands) do
      for _, command in ipairs(commands) do
        if string.lower(command.name) == string.lower(name) then
          return command
        end
      end
    end
  end

  function BSU:FormatCommandArgStr(str)
    return string.Split(str, " ") -- temporary
  end

  function BSU:GetPlayerCommandPermission(ply, name)
    local command = BSU:GetCommandByName(name)

    return not command.hasPermission and true or BSU:GetCommandByName(name).hasPermission(ply)
  end

  function BSU:RunCommand(ply, name, argStr) -- makes a player run a command (DOES NOT CHECK FOR PERMISSION!!!!)
    BSU:GetCommandByName(name).exec(ply, BSU:FormatCommandArgStr(argStr))
  end

  function BSU:PlayerUseCommand(ply, name, argStr)
    if not BSU:GetPlayerCommandPermission(ply, name) then return end -- player doesn't have permission to use this command

    BSU:RunCommand(ply, name, argStr) -- run command serverside
  end

  net.Receive("BSU_RunCommand", function(len, ply)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len)))

    BSU:PlayerUseCommand(ply, data.name, data.argStr)
  end)

  hook.Add("PlayerSay", "BSU_ChatCommand", function(sender, text)
    if string.StartWith(text, BSU.CMD_PREFIX) then -- sender tried to use a command
      local args = string.Split(text, " ")
      local name = string.lower(string.sub(args[1], 2))
      if BSU:GetCommandByName(name) then -- command is valid
        BSU:PlayerUseCommand(sender, name, table.concat(args, " ", 2))
      end
    end
  end)
else
  concommand.Add(
    "bsu",
    function(ply, _, args)
      local command = string.lower(args[1])

      table.remove(args, 1)

      net.Start("BSU_RunCommand")
        net.WriteData(util.Compress(util.TableToJSON({ name = command, argStr = table.concat(args, " ") })))
      net.SendToServer()
    end,
    function(_, text)
      local text = string.lower(string.Trim(text))
      local autoComplete = {}

      for category, commands in pairs(bsuCommands) do
        for _, command in ipairs(commands) do
          if text == "" then -- add all commands
            table.insert(autoComplete, "bsu " .. command.name)
          elseif string.StartWith(string.lower(command.name), text) then
            table.insert(autoComplete, "bsu " .. command.name)
          end
        end
      end

      return autoComplete
    end
  )
end