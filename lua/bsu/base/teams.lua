-- teams.lua by Bonyoze

if SERVER then
    util.AddNetworkString("BSU_TeamsSetup")

    function BSU:GetRanks()
        local ranks = sql.Query("SELECT * FROM bsu_ranks")

        if ranks then
            local tbl = {}
            for _, entry in ipairs(ranks) do
                table.insert(tbl, {
                    index = tonumber(entry.rankIndex),
                    name = entry.rankName,
                    color = BSU:HexToColor(entry.rankColor),
                    userGroup = entry.userGroup
                })
            end
            return tbl
        end
    end

    function BSU:GetRank(index)
        for _, rank in ipairs(BSU:GetRanks()) do
            if rank.index == index then
                return rank
            end
        end
    end

    net.Receive("BSU_TeamsSetup", function(_, ply) -- send team data to client
        local ranks = BSU:GetRanks()
        net.Start("BSU_TeamsSetup")
            net.WriteInt(#ranks, 16)
            for _, v in ipairs(ranks) do
                net.WriteInt(v.index, 16) -- index
                net.WriteString(v.name) -- name
                net.WriteInt(v.color.r, 9) -- color red
                net.WriteInt(v.color.g, 9) -- color green
                net.WriteInt(v.color.b, 9) -- color blue
            end
        net.Send(ply)
    end)

    for _, v in ipairs(BSU:GetRanks()) do -- load team data server-side
        team.SetUp(v.index, v.name, v.color)
    end
else
    net.Receive("BSU_TeamsSetup", function()
        local total = net.ReadInt(16)

        for _ = 1, total do -- load team data client-side
            local index, name, color = net.ReadInt(16), net.ReadString(), Color(net.ReadInt(9), net.ReadInt(9), net.ReadInt(9))
            team.SetUp(index, name, color)
        end
    end)

    hook.Add("InitPostEntity", "BSU_TeamsInit", function()
        net.Start("BSU_TeamsSetup")
        net.SendToServer()
    end)
end