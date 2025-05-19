-- base/server/groups.lua
-- handles the player groups

-- register default groups
if next(BSU.GetAllGroups()) == nil then
	BSU.RegisterGroup("user", 1, "user", "%user")
	BSU.RegisterGroup("admin", 2, "admin", "%admin", "user")
	BSU.RegisterGroup("superadmin", 3, "superadmin", "*", "admin")
end
