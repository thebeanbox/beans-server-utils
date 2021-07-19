-- Created and Mauled by FadeRax64



---- Variables ============================================================================================
surface.CreateFont("fontMain", {font = "Tahoma", size = 15, antialias = true, weight = 600})
net.Receive("BSU_SkyboxNetMessage", function() inSkybox = net.ReadBool() end)
local lPly = LocalPlayer()
local inSkybox, dpStatHud, dpStatIcons, dmBlur
local uvMult = 1/3
local blur = Material("pp/blurscreen") -- USE pp/blurscreen METHOD INSTEAD!!!
local resW, resH = ScrW(), ScrH()
local plyHealth, plyArmor, hasArmor = 0, 0, 0
local stats     = { skybox = false, flashlight = false, buildmode = false }
local hideHuds  = { CHudHealth=true, CHudBattery=true }
local icons     = {
    sheet   = Material("materials/bsu/stathud/stathudIcons16.png"),
    health  = {u = 0,         v = uvMult},
    armor   = {u = uvMult,    v = uvMult},
    light   = {u = 0,         v = 0},
    skybox  = {u = uvMult*2,  v = 0},
    build   = {u = uvMult,    v = 0}
}
local hud       = {
    targetW = 1,            targetH = 1,
    minSize = 0.5,          maxSize = 2,
    x = resW * 0.025,       y = resH * 0.95,
    w = 150,                h = 40
}



---- Functions ============================================================================================
function panelBlur(panel, layers, density, alpha)
    local x, y = panel:LocalToScreen(0, 0)
  
    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blur)
  
    for i = 1, 3 do
      blur:SetFloat("$blur", (i / layers) * density)
      blur:Recompute()
  
      render.UpdateScreenEffectTexture()
      surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end
end

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
    if lPly:IsValid() then
        local barWidth = w-10
        if lPly:Armor()>0 then hasArmor = 1 else hasArmor = 0 end
        local boolHasArmor = !tobool( hasArmor )
        local hudHeight = ( hud.h/2+5) + ((hud.h/2-5)*hasArmor )

        if hud.targetW >= 0.6 then dpStatIcons:Show() else dpStatIcons:Hide() end
        self:SetPos(hud.x, hud.y - ((hudHeight/5) * hasArmor))
        self:SetSize( hud.w, hudHeight )

        plyHealth = Lerp( 0.1, plyHealth, math.Clamp((lPly:Health()/lPly:GetMaxHealth())*barWidth, 0, barWidth) )
        plyArmor = Lerp( 0.1, plyArmor, math.Clamp((lPly:Armor()/lPly:GetMaxArmor())*barWidth, 0, barWidth) )

        -- Draw Background
        panelBlur(self, 5, 10, 50)
        draw.RoundedBox( 5, 0, 0, w, h, Color(0, 0, 0, 200) )
        -- Draw Health Bar
        draw.RoundedBoxEx( 5, 5, 5, barWidth, (hud.h/2)-5, Color(175, 0, 0, 255), true, true, boolHasArmor, boolHasArmor )
        draw.RoundedBoxEx( 5, 5, 5, plyHealth, (hud.h/2)-5, Color(0, 200, 0, 255), true, true, boolHasArmor, boolHasArmor )

        if hud.targetH >= 1 then
            surface.SetDrawColor(Color(255,255,255,255))
            draw.DrawText( lPly:Health(), "fontMain", 30, (hud.h/4)-5, Color(255,255,255,255), 0 )
            surface.SetMaterial( icons.sheet )
            surface.DrawTexturedRectUV( 10, (hud.h/4)-5, 16, 16, icons.health.u, icons.health.v, icons.health.u+uvMult, icons.health.v+uvMult )
        end
        -- Draw Armor Bar
        if hasArmor==1 then
            draw.RoundedBoxEx( 5, 5, h/2, barWidth, (h/2)-5, Color(75, 75, 75, 255), false, false, true, true )
            draw.RoundedBoxEx( 5, 5, h/2, plyArmor, (h/2)-5, Color(0, 150, 255, 255), false, false, true, true )
            if hud.targetH >= 1 then
                surface.SetDrawColor(Color(255,255,255,255))
                draw.DrawText( lPly:Armor(), "fontMain", 30, (h/1.5)-6, Color(255,255,255,255), 0 )
                surface.SetMaterial( icons.sheet )
                surface.DrawTexturedRectUV( 10, (h/1.5)-6, 16, 16, icons.armor.u, icons.armor.v, icons.armor.u+uvMult, icons.armor.v+uvMult )
            end
        end
    end
end

function drawIcons( self, w, h )
    if lPly:IsValid() then
        local hudHeight = ( hud.h/2+5) + ((hud.h/2-5)*hasArmor )

        self:SetPos(hud.x, (hud.y-30) - ((hudHeight/5) * hasArmor))
        self:SetSize( hud.w, 25 )
        panelBlur(self, 5, 10, 50)

        stats.skybox = inSkybox
        stats.flashlight = lPly:FlashlightIsOn()
        stats.buildmode = lPly:HasGodMode()

        if stats.flashlight then 
            draw.RoundedBox( 5, 0, 0, 25, h, Color(0, 0, 0, 200) )
            surface.SetDrawColor(Color(255,255,255,255))
            surface.SetMaterial( icons.sheet )
            surface.DrawTexturedRectUV( (25/4)-1, (h/4)-1, 16, 16, icons.light.u, icons.light.v, icons.light.u+uvMult, icons.light.v+uvMult )
        end

        if !stats.buildmode then -- Currently inverted for debug purposes
            draw.RoundedBox( 5, 30, 0, 25, h, Color(0, 0, 0, 200) )
            surface.SetDrawColor(Color(255,255,255,255))
            surface.SetMaterial( icons.sheet )
            surface.DrawTexturedRectUV( 29+(25/4), (h/4)-1, 16, 16, icons.build.u, icons.build.v, icons.build.u+uvMult, icons.build.v+uvMult )
        end

        if !stats.skybox then -- Currently inverted for debug purposes
            draw.RoundedBox( 5, 60, 0, 25, h, Color(0, 0, 0, 200) )
            surface.SetDrawColor(Color(255,255,255,255))
            surface.SetMaterial( icons.sheet )
            surface.DrawTexturedRectUV( 59+(25/4), (h/4)-1, 16, 16, icons.skybox.u, icons.skybox.v, icons.skybox.u+uvMult, icons.skybox.v+uvMult )
        end
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
        hud.x, hud.y = (resW * 0.025) - (hud.targetH * 10), (resH * 0.95) - (hud.targetH * 10)
        hud.w, hud.h = hud.targetW * 150, hud.targetH * 40
    else
        MsgC( Color(255,0,0), "Must use a number between "..hud.minSize.." and "..hud.maxSize.."!\n" )
    end
end)



---- Hooks ================================================================================================
timer.Simple( 2, initPanel )
hook.Add( "HUDShouldDraw", "StatHud_hideHud", hideHud )
hook.Add( "InitPostEntity", "StatHud_initHud", initPanel )