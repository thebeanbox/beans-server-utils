if SERVER then
    util.AddNetworkString("BSU_menuModerationGetRanks")
    util.AddNetworkString("BSU_menuModerationChangeRank")

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
    local panel = vgui.Create("DPanel")
    panel.Paint = function() end

    local entry = vgui.Create("DTextEntry", panel)
    entry:SetTabbingDisabled(true)
    entry:Dock(TOP)

    local rankList = vgui.Create("DListView", panel)
    rankList:Dock(FILL)
    rankList:SetMultiSelect(false)
    rankList:AddColumn("Ranks")

    net.Start("BSU_menuModerationGetRanks") -- request the ranks
    net.SendToServer()

    local ranks

    net.Receive("BSU_menuModerationGetRanks", function(len) -- setup rank list
        ranks = util.JSONToTable(util.Decompress(net.ReadData(len)))

        table.sort(ranks, function(a, b) return a.index > b.index end)

        for _, v in pairs(ranks) do
            rankList:AddLine(v.name)
        end
    end)

    rankList.OnRowSelected = function(pnl, index, row)
        if not ranks then return end

        local rankIndex
        for _, v in pairs(ranks) do
            if v.name == row:GetValue(1) then
                rankIndex = v.index
                break
            end
        end

        net.Start("BSU_menuModerationChangeRank")
            net.WriteInt(rankIndex, 16)
        net.SendToServer()
    end

    bsuMenu.addPage(3, "Moderation", panel, "icon16/shield.png")
end