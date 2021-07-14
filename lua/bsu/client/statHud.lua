-- Created and Mauled by FadeRax64



---- Variables ============================================================================================
surface.CreateFont("fontMain", {font = "Arial", size = 15, antialias = true, weight = 550})
net.Receive("BSU_SkyboxNetMessage", function() inSkybox = net.ReadBool() end)
local lPly, inSkybox, dpStatHud, dpStatIcons, dmBlur
local blur = Material("pp/toytown-top") -- USE pp/blurscreen METHOD INSTEAD!!!
local resW, resH = ScrW(), ScrH()
local plyHealth, plyArmor, hasArmor = 0, 0, 0
local hideHuds  = { CHudHealth=true, CHudBattery=true }
local icons     = { heart = Material("icon16/heart.png"), shield = Material("icon16/shield.png") }
local hud       = {
    targetW = 1,            targetH = 1,
    minSize = 0.5,          maxSize = 2,
    x = resW * 0.025,       y = resH * 0.925,
    w = 150,                h = 40
}



---- Functions ============================================================================================
function initPanel()
    lPly = LocalPlayer()

    if not dpStatHud then
        dpStatHud = vgui.Create("DFrame")
            dpStatHud:SetPos(hud.x, hud.y)
            dpStatHud:SetSize(hud.w, hud.h/2)
            dpStatHud:SetSizable(false)
            dpStatHud:SetScreenLock(false)
            dpStatHud:ShowCloseButton(false)
            dpStatHud:SetDraggable(false)
            dpStatHud:SetTitle("")
            dpStatHud.Paint = drawHud
    end

    if not dpStatIcons then
        dpStatIcons = vgui.Create("DFrame")
            dpStatIcons:SetPos(hud.x, hud.y-30)
            dpStatIcons:SetSize(hud.w, hud.h/4)
            dpStatIcons:SetSizable(false)
            dpStatIcons:SetScreenLock(false)
            dpStatIcons:ShowCloseButton(false)
            dpStatIcons:SetDraggable(false)
            dpStatIcons:SetTitle("")
            dpStatIcons.Paint = drawIcons
    end
end

function drawHud(self, w, h)
    local barWidth = w-10
    if lPly:Armor() then -- This is disgusting, I gotta think of something else
        if lPly:Armor()>0 then hasArmor = 1 else hasArmor = 0 end
    end
    local boolHasArmor = !tobool( hasArmor )
    local hudHeight = ( hud.h/2+5) + ((hud.h/2-5)*hasArmor )
    self:SetSize( hud.w, hudHeight )

    plyHealth = Lerp( 0.1, plyHealth, math.Clamp((lPly:Health()/lPly:GetMaxHealth())*barWidth, 0, barWidth) )
    plyArmor = Lerp( 0.1, plyArmor, math.Clamp((lPly:Armor()/lPly:GetMaxArmor())*barWidth, 0, barWidth) )

    -- Draw Background
    surface.SetMaterial( blur )
    surface.DrawTexturedRect( 0, 0, w, h )
    draw.RoundedBox( 5, 0, 0, w, h, Color(0, 0, 0, 200) )
    -- Draw Health Bar
    draw.RoundedBoxEx( 5, 5, 5, barWidth, (hud.h/2)-5, Color(175, 0, 0, 255), true, true, boolHasArmor, boolHasArmor )
    draw.RoundedBoxEx( 5, 5, 5, plyHealth, (hud.h/2)-5, Color(0, 200, 0, 255), true, true, boolHasArmor, boolHasArmor )

    if hud.targetH >= 1 then
        draw.DrawText( lPly:Health(), "fontMain", 30, (hud.h/4)-5, Color(255,255,255,255), 0 )
        surface.SetMaterial( icons.heart )
        surface.DrawTexturedRect( 10, (hud.h/4)-5, 16, 16 )
    end
    -- Draw Armor Bar
    if hasArmor==1 then
        draw.RoundedBoxEx( 5, 5, h/2, barWidth, (h/2)-5, Color(75, 75, 75, 255), false, false, true, true )
        draw.RoundedBoxEx( 5, 5, h/2, plyArmor, (h/2)-5, Color(0, 150, 255, 255), false, false, true, true )
        if hud.targetH >= 1 then
            draw.DrawText( lPly:Armor(), "fontMain", 30, (h/1.5)-6, Color(255,255,255,255), 0 )
            surface.SetMaterial( icons.shield )
            surface.DrawTexturedRect( 10, (h/1.5)-6, 16, 16 )
        end
    end
end

function drawIcons( self, w, h )
    self:SetSize( hud.w, 25 )

    if inSkybox then 
        surface.SetMaterial( blur )
        surface.DrawTexturedRect( 0, 0, 25, h )
        draw.RoundedBox( 5, 0, 0, 25, h, Color(0, 0, 0, 200) )
        draw.DrawText( "SKY", "fontMain", 0, h/4, Color(255, 75, 75, 255), 0 )
    end
end

function hideHud( name )
    if hideHuds[name] then
        return false
    end
end

concommand.Add("bsu_hudsize", function(ply, cmd, args)
    local argSize = tonumber(args[1])
    if argSize  and (argSize >= hud.minSize and argSize <= hud.maxSize) then
        hud.targetW, hud.targetH = argSize, argSize
        --hud.x, hud.y = hud.targetW * resW * 0.025, hud.targetH * resH * 0.925
        hud.w, hud.h = hud.targetW * 150, hud.targetH * 40
        --dpStatHud:SetPos(hud.x, hud.y)
        --//dpStatHud:SetSize(hud.w, hud.h/2)
    else
        MsgC( Color(255,0,0), "Must use a number between "..hud.minSize.." and "..hud.maxSize.."!\n" )
    end

end)



---- Hooks ================================================================================================
timer.Simple( 2, initPanel )
hook.Add( "HUDShouldDraw", "StatHud_hideHud", hideHud )
hook.Add( "InitPostEntity", "StatHud_initHud", initPanel )