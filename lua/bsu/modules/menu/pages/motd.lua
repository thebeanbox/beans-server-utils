local panel = vgui.Create("DPanel")
panel.Paint = function() end

local html = vgui.Create("DHTML", panel)
html:Dock(FILL)
html.ConsoleMessage = function() end -- stops html console messages from appearing in the client's console

hook.Add("InitPostEntity", "BSU_MOTDLoadURL", function() -- we have to use this hook because LocalPlayer is not valid when the file initiates
  html:OpenURL("http://beanbox.site.nfoservers.com/motd.html)
end)

bsuMenu.addPage(1, "MOTD", panel, "icon16/star.png") -- add this page to the client's menu as "MOTD"
