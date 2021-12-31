if SERVER then
  return
end

local panel = vgui.Create("DPanel")
panel.Paint = function() end

-- To Do: Make scoreboard

BSU.Menu.addPage(2, "Scoreboard", panel, "icon16/controller.png")
