local panel = vgui.Create("DPanel")
panel.Paint = function() end


--if bsu.Permissions.plyHasPermission(LocalPlayer(), "bsu_isStaffMember") then
    bsuMenu.addPage(4, "Moderation", panel, "icon16/monkey.png")
--end
