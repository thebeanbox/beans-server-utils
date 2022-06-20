-- base/server/groups.lua
-- handles the player groups

-- register default groups
if table.IsEmpty(BSU.GetAllGroups()) then
  BSU.RegisterGroup("user", 1, "user")
  BSU.RegisterGroup("admin", 2, "admin", "user")
  BSU.RegisterGroup("superadmin", 3, "superadmin", "admin")

  -- setup target access
  BSU.AddGroupTargetAccess("user", "user") -- user group can target user group
  BSU.AddGroupTargetAccess("admin", "admin") -- admin group can target admin and user group
  BSU.AddGroupTargetAccess("superadmin", "superadmin") -- superadmin group can target superadmin, admin and user group
  -- (^ this isn't really needed since the "superadmin" usergroup gives this group access to everything)
end