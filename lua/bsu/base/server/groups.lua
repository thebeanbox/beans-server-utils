-- base/server/_groups.lua
-- handles the player groups

-- try to setup default and bot groups (if they don't exist)
if not BSU.GetGroupByID(BSU.DEFAULT_GROUP) then
  BSU.RegisterGroup(BSU.DEFAULT_GROUP, "User", Color(255, 255, 255))
end

if not BSU.GetGroupByID(BSU.BOT_GROUP) then
  BSU.RegisterGroup(BSU.BOT_GROUP, "Bot", Color(0, 128, 255))
end

-- populate server-side teams
BSU.PopulateTeams()

-- send team data to clients
local function clientTeamSetup(ply)
  local groups = BSU.GetAllGroups()
  local teamData = {}
  for _, v in ipairs(groups) do
    teamData[v.id] = { name = v.name, color = BSU.HexToColor(v.color) }
  end

  BSU.ClientRPC(ply, "BSU.PopulateTeams", teamData)
end

hook.Add("PlayerAuthed", "BSU_ClientTeamSetup", clientTeamSetup)