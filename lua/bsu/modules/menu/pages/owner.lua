if SERVER then
    util.AddNetworkString("BSU_MenuChangeUniqueColor")
    net.Receive("BSU_MenuChangeUniqueColor", function() 
        local changereset = net.ReadBool() -- if true, change color, if false, reset color
        local ply = net.ReadEntity()
        if changereset == true then
            BSU:SetPlayerUniqueColor(ply, net.ReadTable())
        elseif changereset == false then
            BSU:ResetPlayerUniqueColor(ply)
        end
    end)

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
        net.Start("BSU_MenuChangeUniqueColor")
        net.WriteBool(true)
        net.WriteEntity(LocalPlayer())
        net.WriteTable(rcc:GetColor())
        net.SendToServer()
    end

    local rcr = vgui.Create("DButton", panel) -- reset color
    rcr:SetPos(75, 255)
    rcr:SetText("Reset Custom Color")
    rcr.DoClick = function()
        net.Start("BSU_MenuChangeUniqueColor")
        net.WriteBool(false)
        net.WriteEntity(LocalPlayer())
        net.SendToServer()
    end
    bsuMenu.addPage(6, "obama guacamole", panel, "icon16/monkey.png")
  end
