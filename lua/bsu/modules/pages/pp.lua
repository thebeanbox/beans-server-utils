if SERVER then
  return
end

local panel = vgui.Create("DPanel")
panel.Paint = function() end

-- To Do: Make prop protection menu

BSU.Menu.addPage(3, "Prop Protection", panel, "icon16/bricks.png")