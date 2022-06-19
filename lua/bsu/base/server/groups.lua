-- base/server/groups.lua
-- handles the player groups

-- register default groups
if table.IsEmpty(BSU.GetAllGroups()) then
  BSU.RegisterGroup("user", 1, "user")
  BSU.RegisterGroup("admin", 2, "admin", "user")
  BSU.RegisterGroup("superadmin", 3, "superadmin", "admin")
end