-- Created and Mauled by FadeRax64

if SERVER then

    // Nothing :( !!

else

    //-- Variables
    surface.CreateFont("fontMain", {font = "Arial", size = 15, antialias = true, weight = 600})
    net.Receive("BSU_SkyboxNetMessage", function() inSkybox = net.ReadBool() end)
    local blur = Material("pp/blurscreen") //-- USE THIS!!!
    local hideHuds = {CHudHealth=true, CHudBattery=true}
    local resW,resH = ScrW(),ScrH()
    local hudX = resW * 0.025
    local hudY = resH * 0.925
    local hudW = 100
    local hudH = 40
    local lPly = LocalPlayer()
    local inSkybox
    local inSkyStr = "loading..."
    local randomNumber = math.random(0, 9999)
    local statHud = vgui.Create("DFrame")
        statHud:SetPos(hudX, hudY)
        statHud:SetSize(hudW, hudH)
        statHud:SetSizable(false)
        statHud:SetScreenLock(false)
        statHud:ShowCloseButton(false)
        statHud:SetDraggable(false)
        statHud:SetTitle("")


    //-- Functions
    function drawHud(self, w, h)
        local plyHealth = math.Clamp(lPly:Health(), 0, 999)
        local plyArmor = math.Clamp(lPly:Armor(), 0, 999)

        draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 255, 100))
    end

    function hideHud(name)
        if hideHuds[name] then
            return false
        end
    end

    
    //-- Hooks
    statHud.Paint = drawHud
    hook.Add("HUDShouldDraw", "statHud_hideHud", hideHud)

end
