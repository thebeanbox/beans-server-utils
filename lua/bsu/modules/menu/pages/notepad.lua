if SERVER then
    

else
  local panel = vgui.Create("DPanel")
  panel.Paint = function() end

  local html = vgui.Create("DHTML", frame)
    html:Dock(FILL)
    html:OpenURL(file.Read("bsu/notepad.txt"), "DATA"))

  bsuMenu.addPage(5, "Notepad", panel, "icon16/pencil.png") -- add this page to the client's menu as "MOTD"
end
