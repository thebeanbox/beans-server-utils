--[[
  Name: help
  Desc: Show a list of all available BSU commands
]]
BSU.SetupCommand("help", function(cmd)
  cmd:SetDescription("Show a list of all available BSU commands")
  cmd:SetFunction(function(self, ply)
    local str = "\n\n[BSU COMMAND LIST]\n\n"
    local categories = BSU.GetCommandCategories()

    for k, v in ipairs(categories) do
      str = str .. "[" .. string.upper(v) .. "]:"
      local cmds = BSU.GetCommandsByCategory(v)
      table.sort(cmds, function(a, b) return a:GetName() < b:GetName() end)
      
      for _, vv in ipairs(cmds) do
        str = str .. "\n\t" .. vv:GetName() .. "\n\t- " .. vv:GetDescription()
      end
      str = str .. "\n\n"
    end

    MsgC(color_white, str)
    chat.AddText("Command help list has been printed to console")
  end)
end)