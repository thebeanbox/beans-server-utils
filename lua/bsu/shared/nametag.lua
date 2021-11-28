-- Created and Mauled by FadeRax64



if SERVER then

    util.AddNetworkString("bsuNameTag_newPlayer")
    util.AddNetworkString("bsuNameTag_plyDisconnect")
    util.AddNetworkString("bsuNameTag_sendPly")

    net.Receive("bsuNameTag_newPlayer", function(len, ply)
        net.Start("bsuNameTag_sendPly")
        net.WriteEntity(ply)
        net.Broadcast()
    end)

    hook.Add("PlayerDisconnected", "toClient_PlayerDisconnect", function(ply)
        net.Start("bsuNameTag_plyDisconnect")
        net.WriteEntity(ply)
        net.Broadcast()
    end)

else

    ---- Variables ============================================================================================
    surface.CreateFont("FontMain", {font = "Arial", size = 20, antialias = true, weight = 600})
    surface.CreateFont("FontSub", {font = "Arial", size = 15, antialias = true, weight = 500})
    local materialData = {}
    local nametags = { panels = {}, avatars = {} }
    local ready = false
    local maxDistance = 1000



    ---- Functions ============================================================================================
    function findPlr(table, ply)
        for k,v in ipairs(table) do
            if v == ply then
                return true
            end
        end
        return false
    end

    function createPanel(ply)
        local data2D = ply:GetPos():ToScreen()
        local plyStats = BSU:GetPlayerValues(ply)

        local panel = vgui.Create("DFrame")
            panel:SetPos( ScrW()/2, ScrH()/2 )
            panel:SetSize( 96, 18 )
            panel:SetTitle( "" )
            panel:SetDraggable( false )
            panel:ShowCloseButton( false )
            panel:SetSizable( false )
            panel:SetDeleteOnClose( false )
            panel.Player = ply
            panel.Paint = drawNameTag

        local avatarImg = vgui.Create("AvatarImage", panel)
            avatarImg:SetPos( 0, 0 )
            avatarImg:SetSize( 18, 18 )
            avatarImg:SetPlayer( ply, 16 )
            panel.avatarImg = avatarImg
        
        table.insert( nametags.panels, panel )
        table.insert( nametags.avatars, avatarImg )
    end

    function initializePanels()
        nametags = { panels = {}, avatars = {} }

        for k,v in ipairs( player.GetAll() ) do
            if v ~= LocalPlayer() then
                createPanel(v)
            end
        end

        net.Start( "bsuNameTag_newPlayer" )
        net.SendToServer()

        ready = true
    end


    function drawNameTag(self, w, h)
        local ply = self.Player
        if ply == nil then
            return
        end
        local data2D = (ply:GetPos() + Vector(0,0,100)):ToScreen()
        local isInRange = ((LocalPlayer():GetPos():Distance(ply:GetPos()) <= maxDistance) and (data2D.visible))

        if isInRange then
            local userStatus = BSU:GetPlayerValues(ply)
            local tSizeX, tSizeY

            surface.SetFont("FontMain")
            local nameW, nameH = surface.GetTextSize(ply:Name())

            draw.RoundedBox( 5, 0, 0, w, h, Color(0,0,0,200) )
            draw.DrawText( ply:Name(), "FontMain", 21, 2, Color(0,0,0,255), 0 )
            draw.DrawText( ply:Name(), "FontMain", 21, 0, BSU:GetPlayerColor(ply), 0 )
            
            local trace = LocalPlayer():GetEyeTrace()

            if trace.Entity:IsValid() and trace.Entity:IsPlayer() and trace.Entity == ply then
                tSizeX, tSizeY = 150, 50
                draw.DrawText( team.GetName(ply:Team()), "FontSub", 21, 18, Color(0,0,0,255), 0 )
                draw.DrawText( team.GetName(ply:Team()), "FontSub", 21, 16, Color(255,255,255), 0 )

                --== Some stats currently non-functional
                for k,v in ipairs(userStatus) do
                    local icoX, icoY = w - ((20 * k) - 4 + v.offset.x), (h/2) + v.offset.y

                    if materialData[v.type] then
                        if materialData[v.type].path ~= v.image then
                            materialData[v.type].path = v.image
                            materialData[v.type].mat = Material(v.image)
                        end
                    else
                        materialData[v.type] = {
                            path = v.image,
                            mat = Material(v.image)
                        }
                    end

                    surface.SetMaterial( materialData[v.type].mat )
                    surface.SetDrawColor( color_white )
                    surface.DrawTexturedRect( icoX, icoY, v.size.x, v.size.y )
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
    hook.Add( "InitPostEntity", "NameTag_InitializePanels", initializePanels )

    net.Receive("bsuNameTag_sendPly", function()
        local sentPly = net.ReadEntity()
        createPanel(sentPly)
    end)

    net.Receive("bsuNameTag_plyDisconnect", function()
        local sentPly = net.ReadEntity()
        for k,v in ipairs(nametags.panels) do
            if v.Player == sentPly then
                v.Paint = nil
                v.avatarImg:Remove()
                v:Close()
                table.remove(nametags.panels, k)
                table.remove(nametags.avatars, k)
                break
            end
        end
    end)
end