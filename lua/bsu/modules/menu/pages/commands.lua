if SERVER then

else
  local panel = vgui.Create("DPanel")
  panel.Paint = function() end

  bsuMenu.addPage(4, "Commands", panel, "icon16/wand.png")
end