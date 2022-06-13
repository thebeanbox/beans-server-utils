local desc_color = Color(180, 180, 180)

--[[
  Name: help
  Desc: Show a list of all available BSU commands
]]
BSU.SetupCommand("help", function(cmd)
  cmd:SetDescription("Show a list of all available BSU commands")
  cmd:SetFunction(function(self, ply)
    local msg = { color_white, "\n\n[BSU COMMAND LIST]\n\n" }
    local categories = BSU.GetCommandCategories()

    for k, v in ipairs(categories) do
      table.Add(msg, { color_white, "[" .. string.upper(v) .. "]:" })

      local cmds = BSU.GetCommandsByCategory(v)
      table.sort(cmds, function(a, b) return a:GetName() < b:GetName() end)
      
      for _, vv in ipairs(cmds) do
        table.Add(msg, { color_white, "\n\t" .. vv:GetName(), desc_color, "\n\t- " .. vv:GetDescription() })
      end
      table.insert(msg, "\n\n")
    end

    MsgC(unpack(msg))
    chat.AddText("Command help list has been printed to console")
  end)
end)