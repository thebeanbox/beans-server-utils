-- base/server/_groups.lua
-- handles the player groups

-- try to setup default and bot groups if they don't exist
if not BSU.GetGroupByID(BSU.DEFAULT_GROUP) then
  BSU.RegisterGroup(BSU.DEFAULT_GROUP, "User", Color(255, 255, 255))
end

if not BSU.GetGroupByID(BSU.BOT_GROUP) then
  BSU.RegisterGroup(BSU.BOT_GROUP, "Bot", Color(0, 128, 255))
end

-- make sure there is atleast 1 admin and superadmin group
if table.IsEmpty(BSU.GetGroupsByUsergroup("admin")) then
  BSU.RegisterGroup(nil, "Admin", Color(0, 100, 0), "admin")
end

if table.IsEmpty(BSU.GetGroupsByUsergroup("superadmin")) then
  BSU.RegisterGroup(nil, "Super Admin", Color(255, 0, 0), "superadmin")
end

-- setup server-side teams
BSU.SetupTeams()

-- setup client-side teams on authed
hook.Add("PlayerAuthed", "BSU_ClientSetupTeams", BSU.ClientSetupTeams)