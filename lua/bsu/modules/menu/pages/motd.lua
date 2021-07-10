local panel = vgui.Create("DPanel")
panel.Paint = function() end

--[[local html = vgui.Create("DHTML", panel)
html:Dock(FILL)
html:OpenURL("http://beanbox.site.nfoservers.com/beans.php?steamid=" .. LocalPlayer():SteamID64())]]

bsuMenu.addPage(1, "MOTD", panel, "icon16/star.png")