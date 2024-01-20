local commandMenu = {}

function commandMenu:Init()
	self:Dock(FILL)
	self:SetDividerWidth(4)
	self:SetLeftMin(100)
	self:SetRightMin(100)
	self:SetLeftWidth(200)

	local commandList = vgui.Create("DCategoryList", self)
	self.commandList = commandList

	for _, categoryName in ipairs(BSU.GetCommandCategories()) do
		local category = commandList:Add(categoryName)
		for _, command in ipairs(BSU.GetCommandsByCategory(categoryName)) do
			local listItem = category:Add(command.name)
			listItem.DoClick = function()
				self:SelectCommand(command)
			end
		end
		category:DoExpansion(false)
	end

	local commandProperties = vgui.Create("DPanel", self)
	commandProperties:DockPadding(10, 10, 10, 10)
	self.commandProperties = commandProperties

	self:SetLeft(commandList)
	self:SetRight(commandProperties)

	self.cmdArgs = {}
end

function commandMenu:SelectCommand(cmd)
	for _, panel in ipairs(self.commandProperties:GetChildren()) do
		panel:Remove()
	end

	self.cmdArgs = cmd.args
	local argvalues = {}

	local titleLabel = vgui.Create("DLabel", self.commandProperties)
	titleLabel:SetText(cmd.name)
	titleLabel:SetTextColor(color_black)
	titleLabel:Dock(TOP)
	titleLabel:SetHeight(30)
	titleLabel:SetFont("BSU_MenuTitle")

	local descriptionLabel = vgui.Create("DLabel", self.commandProperties)
	descriptionLabel:SetText(cmd.desc)
	descriptionLabel:SetTextColor(color_black)
	descriptionLabel:Dock(TOP)
	descriptionLabel:SetFont("BSU_MenuDesc")

	local argPanel = vgui.Create("Panel", self.commandProperties)
	argPanel:Dock(FILL)

	for i, arg in ipairs(self.cmdArgs) do
		local argRow = vgui.Create("Panel", argPanel)
		argRow:Dock(TOP)

		local argName = vgui.Create("DLabel", argRow)
		local labelText = arg.name
		if arg.optional then labelText = labelText .. " (optional)" end
		argName:SetText(labelText)
		argName:SetTextColor(color_black)
		argName:Dock(LEFT)
		argName:SetWidth(self.commandProperties:GetWide() / 2)

		local kind = arg.kind
		if kind == 0 then
			local textEntry = vgui.Create("DTextEntry", argRow)
			textEntry:SetPlaceholderText(labelText)
			textEntry:Dock(FILL)
			textEntry.OnChange = function(s)
				argvalues[i] = "\"" .. s:GetValue() .. "\""
			end
			textEntry.OnValueChange = function(s)
				argvalues[i] = "\"" .. s:GetValue() .. "\""
			end

			if arg.autocomplete then
				textEntry.GetAutoComplete = function()
					local suggestions = {}

					for _, v in ipairs(arg.autocomplete) do
						table.insert(suggestions, v)
					end

					return suggestions
				end
			end

			local clearButton = vgui.Create("DButton", textEntry)
			clearButton:SetText("")
			clearButton:SetIcon("icon16/cancel.png")
			clearButton:SetWidth(24)
			clearButton:Dock(RIGHT)
			clearButton.DoClick = function()
				textEntry:SetValue("")
			end
		elseif kind == 1 then
			local numSlider = vgui.Create("DNumSlider", argRow)
			numSlider:SetMin(arg.min and arg.min or 0)
			numSlider:SetMax(arg.max and arg.max or 1000)
			numSlider:SetValue(arg.default and arg.default or 1)
			if arg.default then numSlider:SetDefaultValue(arg.default) end
			numSlider:SetDark(true)
			numSlider:Dock(FILL)
			numSlider.OnValueChanged = function(_, newStr)
				argvalues[i] = newStr
			end
		elseif kind == 2 then
			local comboBox = vgui.Create("DComboBox", argRow)
			comboBox:AddChoice("[Yourself]", "^")
			for _, ply in ipairs(player.GetAll()) do
				comboBox:AddChoice(ply:Nick(), "$" .. ply:SteamID())
			end
			comboBox:Dock(FILL)
			comboBox.OnSelect = function(_, _, _, data)
				argvalues[i] = data
			end
			comboBox:ChooseOptionID(1)
		elseif kind == 3 then
			local textEntry = vgui.Create("DTextEntry", argRow)
			textEntry:SetPlaceholderText(labelText)
			textEntry:Dock(FILL)
			textEntry.OnChange = function(s)
				argvalues[i] = "\"" .. s:GetValue() .. "\""
			end
			textEntry.OnValueChange = function(s)
				argvalues[i] = "\"" .. s:GetValue() .. "\""
			end

			local optionButton = vgui.Create("DButton", textEntry)
			optionButton:SetText("")
			optionButton:SetIcon("icon16/group.png")
			optionButton:SetWidth(24)
			optionButton:Dock(RIGHT)
			optionButton.DoClick = function()
				local menu = DermaMenu()

				menu:AddOption("[Yourself]", function()
					textEntry:SetValue("^")
				end)

				menu:AddOption("[Everyone]", function()
					textEntry:SetValue("*")
				end)

				for _, ply in ipairs(player.GetAll()) do
					menu:AddOption(ply:Nick(), function()
						textEntry:SetValue(textEntry:GetValue() .. "$" .. ply:SteamID())
					end)
				end

				menu:Open()
			end

			local clearButton = vgui.Create("DButton", textEntry)
			clearButton:SetText("")
			clearButton:SetIcon("icon16/cancel.png")
			clearButton:SetWidth(24)
			clearButton:Dock(RIGHT)
			clearButton.DoClick = function()
				textEntry:SetValue("")
			end
		end
	end

	local executeButton = vgui.Create("DButton", self.commandProperties)
	executeButton:SetText("Execute")
	executeButton.DoClick = function()
		local argstr = table.concat(argvalues, " ")
		print(cmd.name .. " " .. argstr)
		BSU.SafeRunCommand(cmd.name, argstr, false)
	end

	local executeSilentButton = vgui.Create("DButton", self.commandProperties)
	executeSilentButton:SetText("Execute (Silent)")
	executeSilentButton.DoClick = function()
		local argstr = table.concat(argvalues, " ")
		BSU.SafeRunCommand(cmd.name, argstr, true)
	end

	local executePanel = vgui.Create("DHorizontalDivider", self.commandProperties)
	executePanel:Dock(BOTTOM)
	executePanel:SetLeft(executeButton)
	executePanel:SetRight(executeSilentButton)
	executePanel:SetDividerWidth(2)
	executePanel.Think = function()
		local w = self.commandProperties:GetWide()
		executePanel:SetLeftWidth(w / 2)
	end
end

vgui.Register("BSUCommandMenu", commandMenu, "DHorizontalDivider")

hook.Add("BSU_BSUMenuInit", "BSU_CommandMenuInit", function(bsuMenu)
	local menu = vgui.Create("BSUCommandMenu", bsuMenu)
	bsuMenu:AddTab("Commands", 1, menu, "icon16/cog.png")
end)
