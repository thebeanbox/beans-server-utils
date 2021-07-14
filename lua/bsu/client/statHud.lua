-- Created and Mauled by FadeRax64


---- Variables
surface.CreateFont("fontMain", {font = "Arial", size = 15, antialias = true, weight = 550})
net.Receive("BSU_SkyboxNetMessage", function() inSkybox = net.ReadBool() end)
local blur = Material("pp/toytown-top") ---- USE THIS!!!
local plyHealth, plyArmor = 0, 0
local hideHuds = {CHudHealth=true, CHudBattery=true}
local icons = {heart = Material("icon16/heart.png"), shield = Material("icon16/shield.png")}
local resW, resH = ScrW(), ScrH()
local targetW, targetH = 1, 1
local minSize, maxSize = 0.5, 2
local hudX, hudY = resW * 0.025, resH * 0.925
local hudW, hudH = targetW * 150, targetH * 40
local hasArmor = 0
local lPly, inSkybox, dpStatHud, dmBlur
local inSkyStr = "loading..."


---- Functions
function initPanel()
    lPly = LocalPlayer()
    if not dpStatHud then
        dpStatHud = vgui.Create("DFrame")
            dpStatHud:SetPos(hudX, hudY)
            dpStatHud:SetSize(hudW, hudH/2)
            dpStatHud:SetSizable(false)
            dpStatHud:SetScreenLock(false)
            dpStatHud:ShowCloseButton(false)
            dpStatHud:SetDraggable(false)
            dpStatHud:SetTitle("")
            dpStatHud.Paint = drawHud
    end
end

function drawHud(self, w, h)
    local barWidth = w-10
    if lPly:Armor()>0 then hasArmor = 1 else hasArmor = 0 end
    local boolHasArmor = !tobool(hasArmor)
    local hudHeight = (hudH/2+5) + ((hudH/2-5)*hasArmor)
    self:SetSize(hudW, hudHeight)

    plyHealth = Lerp(0.1, plyHealth, math.Clamp((lPly:Health()/lPly:GetMaxHealth())*barWidth, 0, barWidth))
    plyArmor = Lerp(0.1, plyArmor, math.Clamp((lPly:Armor()/lPly:GetMaxArmor())*barWidth, 0, barWidth))

    -- Draw Background
    surface.SetMaterial(blur)
    surface.DrawTexturedRect(0, 0, w, h)
    draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 200))
    -- Draw Health Bar
    draw.RoundedBoxEx(5, 5, 5, barWidth, (hudH/2)-5, Color(175, 0, 0, 255), true, true, boolHasArmor, boolHasArmor)
    draw.RoundedBoxEx(5, 5, 5, plyHealth, (hudH/2)-5, Color(0, 200, 0, 255), true, true, boolHasArmor, boolHasArmor)

    if targetH >= 1 then
        draw.DrawText(lPly:Health(), "fontMain", 30, (hudH/4)-5, Color(255,255,255,255), 0)
        surface.SetMaterial(icons.heart)
        surface.DrawTexturedRect(10, (hudH/4)-5, 16, 16)
    end
    -- Draw Armor Bar
    if hasArmor==1 then
        draw.RoundedBoxEx(5, 5, h/2, barWidth, (h/2)-5, Color(75, 75, 75, 255), false, false, true, true)
        draw.RoundedBoxEx(5, 5, h/2, plyArmor, (h/2)-5, Color(0, 150, 255, 255), false, false, true, true)
        if targetH >= 1 then
            draw.DrawText(lPly:Armor(), "fontMain", 30, (h/1.5)-6, Color(255,255,255,255), 0)
            surface.SetMaterial(icons.shield)
            surface.DrawTexturedRect(10, (h/1.5)-6, 16, 16)
        end
    end
    
    if inSkybox then 
        draw.DrawText("You are in the skybox!", "fontMain", 30, 35, Color(255, 75, 75, 255), 0)
    end
end

function hideHud(name)
    if hideHuds[name] then
        return false
    end
end

concommand.Add("bsu_hudsize", function(ply, cmd, args)
    local argSize = tonumber(args[1])
    if argSize  and (argSize >= minSize and argSize <= maxSize) then
        targetW, targetH = argSize, argSize
        --hudX, hudY = targetW * resW * 0.025, targetH * resH * 0.925
        hudW, hudH = targetW * 150, targetH * 40
        --dpStatHud:SetPos(hudX, hudY)
        dpStatHud:SetSize(hudW, hudH/2)
    else
        MsgC( Color(255,0,0), "Must use a number between "..minSize.." and "..maxSize.."!\n" )
    end

end)


---- Hooks
timer.Simple(2, initPanel)
hook.Add("HUDShouldDraw", "StatHud_hideHud", hideHud)
hook.Add("InitPostEntity", "StatHud_initHud", initPanel)