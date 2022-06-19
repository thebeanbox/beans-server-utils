-- base/server/teams.lua

-- register default teams
if table.IsEmpty(BSU.GetAllTeams()) then
  BSU.RegisterTeam(1, "User", Color(255, 255, 255))
  BSU.RegisterTeam(2, "Admin", Color(0, 100, 0))
  BSU.RegisterTeam(3, "Super Admin", Color(255, 0, 0))
  BSU.RegisterTeam(4, "Bot", Color(0, 127, 255))
end

-- setup teams serverside
BSU.SetupTeams()

-- setup teams clientside on player init
hook.Add("BSU_PlayerInit", "BSU_ClientSetupTeams", BSU.ClientSetupTeams)