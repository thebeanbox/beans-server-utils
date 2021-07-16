-- Created and Mauled by FadeRax64



---- Variables ============================================================================================
surface.CreateFont("FontMain", {font = "Arial", size = 15, antialias = true, weight = 600})
surface.CreateFont("FontSub", {font = "Arial", size = 12, antialias = true, weight = 500})
local icons = {
    wrench = Material("icon16/wrench_orange.png"),
    gun = Material("icon16/gun.png"),
    status_online = Material("icon16/status_online.png"),
    status_busy = Material("icon16/status_busy.png"),
    status_offline = Material("icon16/status_offline.png"),
    region = Material("icon16/flag_red.png"),
    os = Material("icon16/monitor.png")
}
local nametags = { panels = {}, avatars = {} }
local ready = false
local maxDistance = 1000



---- Functions ============================================================================================
function initializePanels()
    nametags = { panels = {}, avatars = {} }

    for k,v in ipairs( player.GetAll() ) do
        if v != LocalPlayer() then
            local data2D = v:GetPos():ToScreen()

            local panel = vgui.Create("DFrame")
                panel:SetPos( ScrW()/2, ScrH()/2 )
                panel:SetSize( 96, 18 )
                panel:SetTitle( "" )
                panel:SetDraggable( false )
                panel:ShowCloseButton( false )
                panel:SetSizable( false )
                panel:SetDeleteOnClose( false )
                panel.Player = v
                panel.Paint = drawNameTag

            if not v:IsBot() then
                local userRegion = BSU:GetPlayerCountry(v)
                local userOS = BSU:GetPlayerOS(v)
                local str = "icon16/monitor.png"

                if userOS != "" then
                    if userOS == "windows" then
                        str = "materials/bsu/scoreboard/windows.png"
                    elseif userOS == "mac" then
                        str = "materials/bsu/scoreboard/mac.png"
                    elseif userOS == "linux" then
                        str = "icon16/tux.png"
                    end

                    panel.OS = Material(str)
                end
                
                if userRegion != "" then
                    panel.Region = Material("flags16/" .. userRegion .. ".png")
                end
            end

            local avatarImg = vgui.Create("AvatarImage", panel)
                avatarImg:SetPos( 0, 0 )
                avatarImg:SetSize( 18, 18 )
                avatarImg:SetPlayer( v, 16 )
                panel.avatarImg = avatarImg
            
            table.insert( nametags.panels, panel )
            table.insert( nametags.avatars, avatarImg )
        end
    end
    ready = true
end


function drawNameTag(self, w, h)
    local ply = self.Player
    local data2D = (ply:GetPos() + Vector(0,0,100)):ToScreen()
    local isInRange = ((LocalPlayer():GetPos():Distance(ply:GetPos()) <= maxDistance) and (data2D.visible))

    if isInRange then
        local userBuildmode = BSU:GetPlayerMode(self.player) == "build" and icons.wrench or icons.gun
        local userStatus = BSU:GetPlayerStatus(ply)
        local tSizeX, tSizeY

        surface.SetFont("FontMain")
        local nameW, nameH = surface.GetTextSize(ply:Name())

        draw.RoundedBox( 5, 0, 0, w, h, Color(0,0,0,200) )
        draw.DrawText( ply:Name(), "FontMain", 21, 1, Color(0,0,0,255), 0 )
        draw.DrawText( ply:Name(), "FontMain", 21, 0, team.GetColor(ply:Team()), 0 )
        
        local trace = LocalPlayer():GetEyeTrace()

        if trace.Entity:IsValid() and trace.Entity:IsPlayer() and trace.Entity == ply then
            tSizeX, tSizeY = 150, 50
            draw.DrawText( team.GetName(ply:Team()), "FontSub", 21, 17, Color(0,0,0,255), 0 )
            draw.DrawText( team.GetName(ply:Team()), "FontSub", 21, 16, Color(255,255,255), 0 )

            --== Some stats currently non-functional
            local icoX,icoY = w/3, h/2.5

            -- User Buildmode Icon
            draw.RoundedBox( 5, icoX, icoY, 20, 20, Color(0,0,0,200) )
            surface.SetMaterial(userBuildmode)
            surface.SetDrawColor(Color(255,255,255,255))
            surface.DrawTexturedRect(icoX+2, icoY+2, 16, 16)

            -- User Active Status Icon
            draw.RoundedBox( 5, icoX+22, icoY, 20, 20, Color(0,0,0,200) )
            surface.SetMaterial(icons["status_"..userStatus])
            surface.SetDrawColor(Color(255,255,255,255))
            surface.DrawTexturedRect(icoX+24, icoY+2, 16, 16)

            -- User Region and Operating System Icon
            if not ply:IsBot() then
                draw.RoundedBox( 5, icoX+44, icoY, 20, 20, Color(0,0,0,200) )
                surface.SetMaterial(self.Region)
                surface.SetDrawColor(Color(255,255,255,255))
                surface.DrawTexturedRect(icoX+46, icoY+2, 16, 16)

                draw.RoundedBox( 5, icoX+66, icoY, 20, 20, Color(0,0,0,200) )
                surface.SetMaterial(self.OS)
                surface.SetDrawColor(Color(255,255,255,255))
                surface.DrawTexturedRect(icoX+68, icoY+2, 16, 16)
            end
        else
            tSizeX, tSizeY = 25+(nameW*1.1), 18
        end

        local posX, posY = data2D.x - (w/2), data2D.y
        self:SetPos( math.Clamp(posX, 0, ScrW()-w), math.Clamp(posY, 0, ScrH()-h) )
        self:SetSize( Lerp(0.1, w, tSizeX), Lerp(0.1, h, tSizeY) )
        self.avatarImg:Show()
    else
        self.avatarImg:Hide()
    end
end


---- Hooks ================================================================================================
if not ready then initializePanels() end
hook.Add( "OnGamemodeLoaded", "NameTag_InitializePanels", initializePanels )