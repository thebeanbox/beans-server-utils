if SERVER then

else
  local panel = vgui.Create("DPanel")
  panel.Paint = function() end

  bsuMenu.addPage(3, "Prop Protection", panel, "icon16/bricks.png")
end