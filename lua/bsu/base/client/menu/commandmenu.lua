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
	titleLabel:SetTextColor(Color(0, 0, 0))
	titleLabel:Dock(TOP)
	titleLabel:SetHeight(30)
	titleLabel:SetFont("BSU_MenuTitle")

	local descriptionLabel = vgui.Create("DLabel", self.commandProperties)
	descriptionLabel:SetText(cmd.desc)
	descriptionLabel:SetTextColor(Color(0, 0, 0))
	descriptionLabel:Dock(TOP)
	descriptionLabel:SetFont("BSU_MenuDesc")

	local commandProperties = vgui.Create("DProperties", self.commandProperties)
	commandProperties:Dock(FILL)

	for argIndex, arg in ipairs(self.cmdArgs) do
		local property = commandProperties:CreateRow("Arguments", arg.name)
		property.DataChanged = function(_, val)
			argvalues[argIndex] = val
		end

		if arg.kind == 0 then -- String
			property:Setup("Generic")
		elseif arg.kind == 1 then -- Number
			local min = arg.min and cmd.args.min or 0
			local max = arg.max and cmd.args.max or 10000
			property:Setup("Int", {min = min, max = max})
		elseif arg.kind == 2 then -- Player
			property:Setup("Combo", {text = "Select a player"})
			for _, v in ipairs(player.GetAll()) do
				if v == LocalPlayer() then continue end
				property:AddChoice(v:Nick(), "$" .. v:SteamID())
			end
			property:AddChoice("[Myself]", "^")
			property:AddChoice("[Random]", "?")
		elseif arg.kind == 3 then -- Players
			property:Setup("Generic")
		end
	end

	local executeButton = vgui.Create("DButton", self.commandProperties)
	executeButton:SetText("Execute")
	executeButton.DoClick = function()
		local argstr = table.concat(argvalues, " ")
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