-- this file is for development

-- !!!!! MAKE SURE YOU REMOVE THIS WHEN THE SERVER GOES PUBLIC !!!!!

if SERVER then
  util.AddNetworkString("BSU_ClearPlayerDB")
  util.AddNetworkString("BSU_SetPlayerRank")
  util.AddNetworkString("BSU_PopulateRankDB")

  net.Receive("BSU_ClearPlayerDB", function()
    sql.Query("DELETE from bsu_players")
  end)

  net.Receive("BSU_SetPlayerRank", function(_, ply)
    BSU:SetPlayerRank(ply, net.ReadInt(16))
  end)

  net.Receive("BSU_PopulateRankDB", function()
    BSU:populateBSURanks()
  end)
else
  -- RESTART SERVER
  concommand.Add("bsu_restartServer",
    function(ply)
      RunConsoleCommand("changelevel", game.GetMap())
    end
  )

  -- REMOVE ALL PLAYER RANK DATA
  concommand.Add("bsu_clearPlayerDB",
    function(ply)
      net.Start("bsu_ClearPlayerDB")
      net.SendToServer()
    end
  )

  -- SET PLAYER RANK
  concommand.Add("bsu_setPlayerRank",
    function(ply, cmd, args)
      for _, v in ipairs(player.GetAll()) do
        if string.lower(v:Nick()) == string.lower(args[1]) then
          net.Start("BSU_SetPlayerRank")
            net.WriteInt(args[2], 16)
          net.SendToServer()
          return
        end
      end
    end
  )

  -- ADD BSU RANKS
  concommand.Add("bsu_populateRankDB",
    function()
      net.Start("bsu_PopulateRankDB")
      net.SendToServer()
    end
  )
end