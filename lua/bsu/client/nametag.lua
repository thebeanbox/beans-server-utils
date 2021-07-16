-- Created and Mauled by FadeRax64



---- Variables ============================================================================================
surface.CreateFont("FontMain", {font = "Arial", size = 15, antialias = true, weight = 600})
surface.CreateFont("FontSub", {font = "Arial", size = 12, antialias = true, weight = 500})
local nametags = { panels = {}, avatars = {} }
local ready = false
local maxDistance = 1000



---- Functions ============================================================================================
function initializePanels()
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

            local avatarImg = vgui.Create("AvatarImage", panel)
                avatarImg:SetPos( 0, 0 )
                avatarImg:SetSize( 18, 18 )
                avatarImg:SetPlayer( v, 16 )
            
            table.insert( nametags.panels, panel )
            table.insert( nametags.avatars, avatarImg )
        end
    end
    ready = true
end


function drawNameTag(self, w, h)
    local ply = self.Player
    local isInRange = (LocalPlayer():GetPos():Distance(ply:GetPos()) <= maxDistance)

    if isInRange then
        local data2D = (ply:GetPos() + Vector(0,0,100)):ToScreen()
        local tSizeX, tSizeY


        surface.SetFont("FontMain")
        local nameW, nameH = surface.GetTextSize(ply:Name())

        draw.RoundedBox( 5, 0, 0, w, h, Color(0,0,0,200) )
        draw.DrawText( ply:Name(), "FontMain", 21, 0, team.GetColor(ply:Team()), 0 )
        
        local trace = LocalPlayer():GetEyeTrace()

        if trace.Entity:IsValid() and trace.Entity:IsPlayer() and trace.Entity == ply then
            tSizeX, tSizeY = 150, 40
            draw.DrawText( team.GetName(ply:Team()), "FontSub", 21, 16, Color(255,255,255), 0 )
        else
            tSizeX, tSizeY = 25+(nameW*1.1), 18
        end

        local posX, posY = data2D.x - (w/2), data2D.y
        self:SetPos( math.Clamp(posX, 0, ScrW()-w), math.Clamp(posY, 0, ScrH()-h) )
        self:SetSize( Lerp(0.1, w, tSizeX), Lerp(0.1, h, tSizeY) )
    end
end


---- Hooks ================================================================================================
if not ready then initializePanels() end
hook.Add( "OnGamemodeLoaded", "NameTag_InitializePanels", initializePanels )