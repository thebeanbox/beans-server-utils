local groupsMenu = {}

function groupsMenu:Init()
	self:Dock(FILL)
	self:SetDividerWidth(4)
	self:SetLeftMin(100)
	self:SetRightMin(100)
	self:SetLeftWidth(200)
end

vgui.Register("BSUGroupsMenu", groupsMenu, "DHorizontalDivider")

hook.Add("BSU_BSUMenuInit", "BSU_GroupsMenuInit", function(bsuMenu)
	--local groupsMenu = vgui.Create("BSUGroupsMenu", bsuMenu)
	--bsuMenu:AddTab("Privileges", 3, groupsMenu, "icon16/group.png")
end)