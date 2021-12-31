if SERVER then
  return
end

local panel = vgui.Create("DPanel")
panel.Paint = function() end

local html = vgui.Create("DHTML", panel)
html:Dock(FILL)
html.ConsoleMessage = function() end -- stops html console messages from appearing in the client's console

html:AddFunction("glua", "guiOpenURL", function(url) -- opening links from within javascript to gmod
  BSU.Menu.hide()
  gui.OpenURL(url)
end)

html:OpenURL("http://beanbox.site.nfoservers.com/motd.html")

BSU.Menu.addPage(1, "MOTD", panel, "icon16/information.png")