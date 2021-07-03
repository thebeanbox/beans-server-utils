-- Created and Mauled by FadeRax64

if SERVER then

    // Nothing :( !!

else

    //-- Variables
    surface.CreateFont("fontMain", {font = "Arial", size = 15, antialias = true, weight = 550})
    net.Receive("BSU_SkyboxNetMessage", function() inSkybox = net.ReadBool() end)
    local blur = Material("pp/blurscreen") //-- USE THIS!!!
    local plyHealth, plyArmor = 0, 0
    local hideHuds = {CHudHealth=true, CHudBattery=true}
    local icons = {heart = Material("icon16/heart.png"), shield = Material("icon16/shield.png")}
    local resW,resH = ScrW(),ScrH()
    local hudX = resW * 0.025
    local hudY = resH * 0.925
    local hudW = 150
    local hudH = 40
    local hasArmor = 0
    local lPly, inSkybox
    local inSkyStr = "loading..."

    //-- Functions
    function initPanel()
        lPly = LocalPlayer()
        statHud = vgui.Create("DFrame")
            statHud:SetPos(hudX, hudY)
            statHud:SetSize(hudW, hudH/2)
            statHud:SetSizable(false)
            statHud:SetScreenLock(false)
            statHud:ShowCloseButton(false)
            statHud:SetDraggable(false)
            statHud:SetTitle("")
            statHud.Paint = drawHud
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
        draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 200))
        -- Draw Health Bar
        draw.RoundedBoxEx(5, 5, 5, barWidth, 15, Color(175, 0, 0, 255), true, true, boolHasArmor, boolHasArmor)
        draw.RoundedBoxEx(5, 5, 5, plyHealth, 15, Color(0, 200, 0, 255), true, true, boolHasArmor, boolHasArmor)
        draw.DrawText(lPly:Health(), "fontMain", 30, 5, Color(255,255,255,255), 0)
        surface.SetMaterial(icons.heart)
        surface.DrawTexturedRect(10, 5, 16, 16)
        -- Draw Armor Bar
        if hasArmor==1 then
            draw.RoundedBoxEx(5, 5, 20, barWidth, 15, Color(75, 75, 75, 255), false, false, true, true)
            draw.RoundedBoxEx(5, 5, 20, plyArmor, 15, Color(0, 150, 255, 255), false, false, true, true)
            draw.DrawText(lPly:Armor(), "fontMain", 30, 20, Color(255,255,255,255), 0)
            surface.SetMaterial(icons.shield)
            surface.DrawTexturedRect(10, 20, 16, 16)
        end
    end

    function hideHud(name)
        if hideHuds[name] then
            return false
        end
    end

    
    //-- Hooks
    initPanel()
    hook.Add("HUDShouldDraw", "statHud_hideHud", hideHud)
    hook.Add("InitPostEntity", "statHud_initHud", initPanel)
end
