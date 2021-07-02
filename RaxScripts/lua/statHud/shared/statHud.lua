-- Created and Mauled by FadeRax64

if SERVER then

    // Nothing :( !!

else

    //-- Variables
    local hideHuds = {["CHudHealth"]=true, ["CHudBattery"]=true}
    local resW,resH = ScrW(),ScrH()
    local hudX = resW * 0.1
    local hudY = resH * 0.9
    local hudW = 100
    local hudH = 60


    //-- Functions
    function drawHud()
        draw.RoundedBox(5, hudX, hudY, hudW, hudH, Color(0,0,0,50))
    end

    function hideHud(name)
        if hide[name] then
            return false
        end
    end


    //-- Hooks
    hook.add("HUDPaint", "statHud_drawHud", drawHud)
    hook.add("HUDShouldDraw", "statHud_hideHud", hideHud)

end