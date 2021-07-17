if SERVER then

else
    local panel = vgui.Create("DPanel")
    panel.Paint = function() end
  
    local rcc = vgui.Create("DColorMixer", panel)
    rcc:SetPalette(false) 
    rcc:SetAlphaBar(false) 
    rcc:SetWangs(true)
    rcc:SetLabel("Rank Color Setter")
    rcc:SetColor(BSU:GetPlayerColor(LocalPlayer()))

    local rcs = vgui.Create("DButton", panel) -- confirm button
    rcs:SetPos(15, 255)
    rcs:SetText("Confirm Color Selection")
    rcs.DoClick = function()
        Msg(LocalPlayer():IsValid())
        BSU:SetPlayerUniqueColor(LocalPlayer(), rcc:GetColor())
    end

    local rcr = vgui.Create("DButton", panel) -- reset color
    rcr:SetPos(75, 255)
    rcr:SetText("Reset Custom Color")
    rcr.DoClick = function()
        BSU:ClearPlayerUniqueColor(LocalPlayer())
    end
    bsuMenu.addPage(6, "obama guacamole", panel, "icon16/monkey.png")
  end
