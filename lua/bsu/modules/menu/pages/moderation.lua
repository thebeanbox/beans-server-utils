if SERVER then
    util.AddNetworkString("BSU_menuModerationGetRanks")

    net.Receive("BSU_menuModerationGetRanks", function(_, ply)
        net.Start("BSU_menuModerationGetRanks")
            net.WriteData(util.Compress(util.TableToJSON(BSU:GetRanks())))
        net.Send(ply)
    end)

    net.Receive("BSU_menuModerationChangeRank", function(_, ply)
        if BSU:PlayerIsSuperAdmin(ply) then
            BSU:SetPlayerRank(ply, net.ReadInt(16))
        end
    end)
else
    net.Start("BSU_menuModerationGetRanks") -- request the ranks
    net.SendToServer()

    local panel = vgui.Create("DCategoryList")
    panel.Paint = function() end

    panel:Add("Note: this is not finished")

    -- players management
    local playersManage = vgui.Create("DPanel")
    playersManage:DockPadding(5, 5, 5, 5)

    playersManage.playersList = vgui.Create("DListView", playersManage)
    playersManage.playersList:SetPos(5, 5)
    playersManage.playersList:SetSize(250, 200)
    playersManage.playersList:SetMultiSelect(false)
    playersManage.playersList:SetSortable(false)

    playersManage.playersList:AddColumn("Steam ID")
    playersManage.playersList:AddColumn("Name")

    playersManage.players = {}
    hook.Add("Think", playersManage, function(self)
        for _, player in ipairs(player.GetAll()) do
            local valid = false
            for _, v in ipairs(self.players) do
                if player == v.player then
                    valid = true
                    break
                end
            end
            if not valid then
                local line = self.playersList:AddLine(player:SteamID(), player:Nick())
                table.insert(self.players, {
                    player = player,
                    line = line,
                })
            end
        end

        for k, v in ipairs(self.players) do
            if not v.player or not v.player:IsValid() then
                self.playersList:RemoveLine(v.line:GetID())
                table.remove(self.players, k)
            else
                v.line:SetColumnText(1, v.player:SteamID())
                v.line:SetColumnText(2, v.player:Nick())
            end
        end
    end)

    local playersCategory = panel:Add("Players Management")
    playersCategory:SetContents(playersManage)
    playersCategory:SetExpanded(false)

    -- ranks management
    local ranksManage = vgui.Create("DPanel")
    ranksManage:DockPadding(5, 5, 5, 5)

    ranksManage.ranksList = vgui.Create("DListView", ranksManage)
    ranksManage.ranksList:SetPos(5, 5)
    ranksManage.ranksList:SetSize(200, 200)
    ranksManage.ranksList:SetMultiSelect(false)
    ranksManage.ranksList:SetSortable(false)

    ranksManage.ranksList:AddColumn("Index")
    ranksManage.ranksList:AddColumn("Name")

    local ranksCategory = panel:Add("Ranks Management")
    ranksCategory:SetContents(ranksManage)
    ranksCategory:SetExpanded(false)

    ranksManage.ranks = {}

    ranksManage.ranksList.OnRowSelected = function(pnl, index, row)
        if not ranks then return end

        local rankIndex
        for _, v in pairs(ranksManage.ranks) do
            if v.name == row:GetValue(1) then
                rankIndex = v.index
                break
            end
        end

        net.Start("BSU_menuModerationChangeRank")
            net.WriteInt(rankIndex, 16)
        net.SendToServer()
    end

    net.Receive("BSU_menuModerationGetRanks", function(len) -- setup rank list
        ranksManage.ranks = util.JSONToTable(util.Decompress(net.ReadData(len)))

        table.sort(ranksManage.ranks, function(a, b) return a.index < b.index end)

        for _, v in pairs(ranksManage.ranks) do
            ranksManage.ranksList:AddLine(v.index, v.name)
        end
    end)

    bsuMenu.addPage(5, "Moderation", panel, "icon16/shield.png")
end