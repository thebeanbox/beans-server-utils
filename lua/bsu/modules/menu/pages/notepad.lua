if SERVER then
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
  
  local html = vgui.Create("DHTML", frame)
  html:Dock(FILL)
  
  net.Start("BSU_menuNotepadData")
  net.SendToServer()

  net.Receive("BSU_menuNotepadData", function(len)
    local url = util.Decompress(net.ReadData(len))
    html:OpenURL(url)
  end)
end
