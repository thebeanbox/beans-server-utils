if SERVER then
    

else
  local panel = vgui.Create("DPanel")
  panel.Paint = function() end

  local html = vgui.Create("DHTML", frame)
    html:Dock(FILL)
    local url = file.Read("bsu/notepad.txt")
    html:OpenURL(url, "DATA")

  bsuMenu.addPage(5, "Notepad", panel, "icon16/pencil.png") -- add this page to the client's menu as "MOTD"
end
