-- Created and Mauled by FadeRax64

if SERVER then

    // Nothing :( !!

else

    //-- Variables
    surface.CreateFont("fontMain", {
        font = "Arial",
        size = 13,
        antialias = true
    })
    local blur = Material("pp/blurscreen")
    local hideHuds = {CHudHealth=true, CHudBattery=true}
    local resW,resH = ScrW(),ScrH()
    local hudX = resW * 0.05
    local hudY = resH * 0.9
    local hudW = 100
    local hudH = 40


    //-- Functions
    function drawHud()
        draw.RoundedBox(5, hudX, hudY, hudW, hudH, Color(0,0,0,100))
        draw.DrawText("Ball Fondler", "fontMain", hudX+10, hudY+10, Color(255,255,255,255), 0)
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