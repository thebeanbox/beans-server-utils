if SERVER then

else
    local panel = vgui.Create("DPanel")
    panel.Paint = function() end
  
    local rcc = vgui.Create("DColorMixer", panel)
    rcc:SetPalette(false) 
    rcc:SetAlphaBar(false) 
    rcc:SetWangs(true) 
    rcc:SetColor(BSU:GetPlayerColor(LocalPlayer()))
  
    bsuMenu.addPage(6, "obama guacamole", panel, "icon16/monkey.png")
  end
