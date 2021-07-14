local panel = vgui.Create("DPanel")
panel.Paint = function() end

local entry = vgui.Create("DTextEntry", panel)
entry:SetTabbingDisabled(true) -- this is needed because you have to be holding TAB to open the menu
entry:Dock(TOP)

--if bsu.Permissions.plyHasPermission(LocalPlayer(), "bsu_isStaffMember") then
    bsuMenu.addPage(4, "Moderation", panel, "icon16/monkey.png")
--end
