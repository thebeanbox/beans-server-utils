-- this file is to easily restart the server

-- !!!!! MAKE SURE YOU REMOVE THIS WHEN THE SERVER GOES PUBLIC !!!!!

concommand.Add("restartserver", function(ply)
  RunConsoleCommand("changelevel", game.GetMap()) -- Reload the same map
end)