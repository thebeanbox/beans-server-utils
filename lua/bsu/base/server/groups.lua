-- base/server/_groups.lua
-- handles the player groups

-- try to setup default and bot groups (if they don't exist)
if not BSU.GetGroupByID(BSU.DEFAULT_GROUP) then
  BSU.RegisterGroup(BSU.DEFAULT_GROUP, "User", Color(255, 255, 255))
end

if not BSU.GetGroupByID(BSU.BOT_GROUP) then
  BSU.RegisterGroup(BSU.BOT_GROUP, "Bot", Color(0, 128, 255))
end

-- setup server-side teams
BSU.SetupTeams()

-- setup client-side teams on authed
hook.Add("PlayerAuthed", "BSU_ClientSetupTeams", BSU.ClientSetupTeams)