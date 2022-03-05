-- lib/server/privileges.lua
-- functions for managing group and player privileges

function BSU.RegisterGroupPrivilege(groupid, type, value, granted)
  -- incase this privilege is already registered, remove the old one
  BSU.RemoveGroupPrivilege(groupid, type, value) -- sqlite's REPLACE INTO could've been implemented but removing and inserting is practically the same

  BSU.SQLInsert(BSU.SQL_GROUP_PRIVS, {
    groupid = groupid,
    type = type,
    value = value,
    granted = granted and 1 or 0
  })
end

function BSU.RegisterPlayerPrivilege(steamid, type, value, granted)
  steamid = BSU.ID64(steamid)

  -- incase this privilege is already registered, remove the old one
  BSU.RemovePlayerPrivilege(steamid, type, value) -- sqlite's REPLACE INTO could've been implemented but removing and inserting is practically the same

  BSU.SQLInsert(BSU.SQL_PLAYER_PRIVS, {
    steamid = steamid,
    type = type,
    value = value,
    granted = granted and 1 or 0
  })
end

function BSU.RemoveGroupPrivilege(groupid, type, value)
  BSU.SQLDeleteByValues(BSU.SQL_GROUP_PRIVS, {
    groupid = groupid,
    type = type,
    value = value
  })
end

function BSU.RemovePlayerPrivilege(steamid, type, value)
  BSU.SQLDeleteByValues(BSU.SQL_PLAYER_PRIVS, {
    steamid = BSU.ID64(steamid),
    type = type,
    value = value
  })
end

function BSU.GetAllGroupPrivileges()
  return BSU.SQLSelectAll(BSU.SQL_GROUP_PRIVS)
end

function BSU.GetAllPlayerPrivileges()
  return BSU.SQLSelectAll(BSU.SQL_PLAYER_PRIVS)
end

function BSU.GetGroupWildcardPrivileges(groupid, type)
  local query = BSU.SQLQuery("SELECT * FROM '%s' WHERE groupid = %s AND type = %s AND value LIKE '%s'",
    BSU.EscOrNULL(BSU.SQL_GROUP_PRIVS, true),
    BSU.EscOrNULL(groupid),
    BSU.EscOrNULL(type),
    "%*%"
  )
  return query and BSU.SQLParse(query, BSU.SQL_GROUP_PRIVS) or {}
end

function BSU.GetPlayerWildcardPrivileges(steamid, type)
  local query = BSU.SQLQuery("SELECT * FROM '%s' WHERE steamid = %s AND type = %s AND value LIKE '%s'",
    BSU.EscOrNULL(BSU.SQL_PLAYER_PRIVS, true),
    BSU.EscOrNULL(BSU.ID64(steamid)),
    BSU.EscOrNULL(type),
    "%*%"
  )
  return query and BSU.SQLParse(query, BSU.SQL_PLAYER_PRIVS) or {}
end

-- returns bool if a group is granted the privilege (or nothing if the privilege is not registered)
function BSU.CheckGroupPrivilege(groupid, type, value)
  -- check for group privilege
  local priv = BSU.SQLSelectByValues(BSU.SQL_GROUP_PRIVS, { groupid = groupid, type = type, value = value })[1]

  if priv then
    return priv.granted == 1
  else
    -- check wildcard privileges
    local wildcards = BSU.GetGroupWildcardPrivileges(groupid, type)
    table.sort(wildcards, function(a, b) return #a.value > #b.value end)
    
    for _, v in ipairs(wildcards) do
      if string.find(value, string.Replace(v.value, "*", "(.-)")) ~= nil then
        return v.granted == 1
      end
    end

    -- check for privilege in inherited group
    local query = BSU.SQLSelectByValues(BSU.SQL_GROUPS, { id = groupid })[1]
    if query then
      return BSU.CheckGroupPrivilege(query.inherit, type, value)
    end
  end
end

-- returns bool if the player is granted the privilege (or nothing if the privilege is not registered in the player's group)
function BSU.CheckPlayerPrivilege(steamid, type, value)
  steamid = BSU.ID64(steamid)

  -- check for player privilege
  local priv = BSU.SQLSelectByValues(BSU.SQL_PLAYER_PRIVS, { steamid = steamid, type = type, value = value })[1]

  if priv then
    return priv.granted == 1
  else
    -- check wildcard privileges
    local wildcards = BSU.GetPlayerWildcardPrivileges(steamid, type)
    table.sort(wildcards, function(a, b) return #a.value > #b.value end)
    
    for _, v in ipairs(wildcards) do
      if string.find(value, string.Replace(v.value, "*", "(.-)")) ~= nil then
        return v.granted == 1
      end
    end

    -- check for privilege in player's group
    local query = BSU.SQLSelectByValues(BSU.SQL_PLAYERS, { steamid = steamid })[1]
    if query then
      return BSU.CheckGroupPrivilege(groupid, type, value)
    end
  end
end

-- returns bool if the player is allowed to spawn/tool something
function BSU.PlayerIsAllowed(ply, type, privilege)
  local check = BSU.CheckPlayerPrivilege(ply:SteamID64(), type, privilege)
  return check == nil or check == true
end