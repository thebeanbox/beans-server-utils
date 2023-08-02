-- base/server/teams.lua

-- register default teams
if next(BSU.GetAllTeams()) == nil then
	BSU.RegisterTeam(1, "User", Color(255, 255, 255))
	BSU.RegisterTeam(2, "Admin", Color(0, 100, 0))
	BSU.RegisterTeam(3, "Super Admin", Color(255, 0, 0))
	BSU.RegisterTeam(4, "Bot", Color(0, 127, 255))
end

-- setup teams serverside
BSU.SetupTeams()

-- setup teams clientside on player activate
gameevent.Listen("player_activate")
hook.Add("player_activate", "BSU_ClientSetupTeams", function(data)
	BSU.ClientSetupTeams(Player(data.userid))
end)