-- commands.lua by Bonyoze

bsuCommands = bsuCommands or {}

if SERVER then
  util.AddNetworkString("BSU_ClientLoadCommands")

	function BSU:RegisterCommand(data)
    if not data.category then
      data.category = "miscellaneous"
    end
    local category = data.category
    
    if not bsuCommands[category] then bsuCommands[category] = {} end

    data.category = nil -- we no longer need this value
    table.insert(bsuCommands[category], data)
  end

  net.Receive("BSU_ClientLoadCommands", function(_, ply)
    local cmdData = {}

    for category, commands in pairs(bsuCommands) do
      cmdData[category] = {}
      for _, command in ipairs(commands) do
        local tbl = table.Copy(command)
        tbl.exec = nil -- don't send the command's function

        table.insert(cmdData[category], tbl)
      end
    end

    net.Start("BSU_ClientLoadCommands")
      net.WriteData(util.Compress(util.TableToJSON(cmdData)))
    net.Send(ply)
  end)
else
  concommand.Add(
    "bsu",
    function(ply, cmd, args, argStr)
      PrintTable(args)
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

  hook.Add("InitPostEntity", "BSU_CommandsInit", function()
    net.Start("BSU_ClientLoadCommands")
    net.SendToServer()

    net.Receive("BSU_ClientLoadCommands", function(len)
      bsuCommands = util.JSONToTable(util.Decompress(net.ReadData(len)))
      PrintTable(bsuCommands) -- test
    end)
  end)
end