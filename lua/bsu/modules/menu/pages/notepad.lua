/*if SERVER then
  util.AddNetworkString("BSU_menuNotepadData")
  
  net.Receive("BSU_menuNotepadData", function(_, ply)
    if BSU:PlayerIsStaff(ply) then
      net.Start("BSU_menuNotepadData")
        net.WriteData(util.Compress(file.Read("bsu/notepad.txt", "DATA")))
      net.Send(ply)
    end
  end)
else
  local panel = vgui.Create("DPanel")
  panel.Paint = function() end
  
  panel.html = vgui.Create("DHTML", panel)
  panel.html:Dock(FILL)

  panel.html.ConsoleMessage = function() end
  
  net.Start("BSU_menuNotepadData")
  net.SendToServer()

  net.Receive("BSU_menuNotepadData", function(len)
    local url = util.Decompress(net.ReadData(len))
    panel.html:OpenURL(url)
  end)
  
  bsuMenu.addPage(5, "Notepad", panel, "icon16/pencil.png")
end
