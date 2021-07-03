-- Created and Mauled by FadeRax64

if SERVER then

    // Nothing :( !!

else

    //-- Variables
    surface.CreateFont("fontMain", {font = "Arial", size = 15, antialias = true, weight = 600})
    net.Receive("BSU_SkyboxNetMessage", function() inSkybox = net.ReadBool() end)
    local blur = Material("pp/blurscreen") //-- USE THIS!!!
    local plyHealth, plyArmor = 0, 0
    local hideHuds = {CHudHealth=true, CHudBattery=true}
    local resW,resH = ScrW(),ScrH()
    local hudX = resW * 0.025
    local hudY = resH * 0.925
    local hudW = 150
    local hudH = 30
    local lPly = LocalPlayer()
    local inSkybox
    local inSkyStr = "loading..."

    local randomNumber = math.random(0, 9999)

    //-- Functions
    function initPanel()
        statHud = vgui.Create("DFrame")
            statHud:SetPos(hudX, hudY)
            statHud:SetSize(hudW, hudH)
            statHud:SetSizable(false)
            statHud:SetScreenLock(false)
            statHud:ShowCloseButton(false)
            statHud:SetDraggable(false)
            statHud:SetTitle("")
            statHud.Paint = drawHud
    end

    function drawHud(self, w, h)
        local barWidth = w-10
        plyHealth = Lerp(0.1, plyHealth, math.Clamp((lPly:Health()/lPly:GetMaxHealth())*barWidth, 0, barWidth))
        plyArmor = Lerp(0.1, plyArmor, math.Clamp((lPly:Armor()/lPly:GetMaxArmor())*barWidth, 0, barWidth))

        -- Draw Background
        draw.RoundedBox(10, 0, 0, w, h, Color(0, 0, 0, 100))
        -- Draw Health Bar
        draw.RoundedBox(10, 5, 5, barWidth, 20, Color(200, 0, 0, 255))
        draw.RoundedBox(10, 5, 5, plyHealth, 20, Color(0, 255, 0, 255))
        -- Draw Armor Bar
        draw.RoundedBox(20, 5, 20, plyArmor, 5, Color(0, 150, 255, 255))
    end

    function hideHud(name)
        if hideHuds[name] then
            return false
        end
    end

    
    //-- Hooks
    hook.Add("HUDShouldDraw", "statHud_hideHud", hideHud)
    hook.Add("InitPostEntity", "BSU_ChatboxInit", initPanel)
end
