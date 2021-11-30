if SERVER then

else
  local panel = vgui.Create("DPanel")
  panel.Paint = function() end

  local html = vgui.Create("DHTML", panel)
  html:Dock(FILL)
  html.ConsoleMessage = function() end -- stops html console messages from appearing in the client's console

  html:AddFunction("glua", "guiOpenURL", function(url) -- opening links from within javascript to gmod
    bsuMenu.hide()
    gui.OpenURL(url)
  end)

  html:OpenURL("http://beanbox.site.nfoservers.com/motd.html")

  bsuMenu.addPage(1, "MOTD", panel, "icon16/information.png") -- add this page to the client's menu as "MOTD"
end