local desc_color = Color(180, 180, 180)

--[[
	Name: help
	Desc: Show a list of all available BSU commands
]]
BSU.SetupCommand("help", function(cmd)
	cmd:SetDescription("Show a list of all available BSU commands")
	cmd:SetAccess(BSU.CMD_CONSOLE)
	cmd:SetFunction(function(self)
		local msg = { color_white, "\n\n[BSU COMMAND LIST]\n\n" }
		local categories = BSU.GetCommandCategories()

		for _, v in ipairs(categories) do
			table.Add(msg, { color_white, "[" .. string.upper(v) .. "]:" })

			local cmds = BSU.GetCommandsByCategory(v)
			table.sort(cmds, function(a, b) return a:GetName() < b:GetName() end)

			for _, vv in ipairs(cmds) do
				table.Add(msg, { color_white, "\n\t" .. vv:GetName(), desc_color, "\n\t- " .. vv:GetDescription() })
			end
			table.insert(msg, "\n\n")
		end

		self:PrintConsoleMsg(unpack(msg))
		self:PrintChatMsg("Command help list has been printed to console")
	end)
end)
