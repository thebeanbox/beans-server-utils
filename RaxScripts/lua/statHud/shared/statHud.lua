-- Created and Mauled by FadeRax64

if SERVER then

    // Nothing :( !!

else

    //-- Variables
    surface.CreateFont("fontMain", {
        font = "Arial",
        size = 15,
        antialias = true,
        weight = 600
    })
    local blur = Material("pp/blurscreen")
    local hideHuds = {CHudHealth=true, CHudBattery=true}
    local resW,resH = ScrW(),ScrH()
    local hudX = resW * 0.025
    local hudY = resH * 0.925
    local hudW = 100
    local hudH = 40
    local lPly = LocalPlayer()
    local inSkybox
    local inSkyStr = "Dummy Text!"
    local randomNumber = math.random(0, 9999)

    net.Receive("BSU_SkyboxNetMessage", function()
        inSkybox = net.ReadBool()
    end)

    //-- Functions
    function drawHud()
        local plyHealth = math.Clamp(lPly:Health(), 0, 999)
        local plyArmor = math.Clamp(lPly:Armor(), 0, 999)

        

        draw.DrawText("v. "..randomNumber, "fontMain", hudX+5, hudY-10, Color(255,0,0,255), 0)

        draw.RoundedBox(5, hudX, hudY, hudW, hudH, Color(0,0,0,100))
        draw.DrawText("Health: "..plyHealth, "fontMain", hudX+5, hudY+5, Color(255,255,255,255), 0)
        draw.DrawText("Armor: "..plyArmor, "fontMain", hudX+5, hudY+20, Color(255,255,255,255), 0)
        
        if inSkybox then inSkyStr = "YOU ARE IN SKYBOX!!!" else inSKyStr = "YOU ARE NOT IN THE SKYBOX!!!!!!" end
        draw.DrawText(inSkyStr, "fontMain", hudX+5, hudY+35, Color(255,0,0,255), 0)
    end

    function hideHud(name)
        if hideHuds[name] then
            return false
        end
    end


    //-- Hooks
    hook.Add("HUDPaint", "statHud_drawHud", drawHud)
    hook.Add("HUDShouldDraw", "statHud_hideHud", hideHud)

end