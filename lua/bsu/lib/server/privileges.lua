-- lib/server/privileges.lua
-- functions for managing group and player privileges

function BSU.RegisterGroupPrivilege(groupid, type, value, granted)
  -- incase this privilege is already registered, remove the old one
  BSU.RemoveGroupPrivilege(groupid, type, value)

  BSU.SQLInsert(BSU.SQL_GROUP_PRIVILEGES,
    {
      groupid = groupid,
      type = type,
      value = value,
      granted = granted and 1 or 0
    }
  )
end

function BSU.RegisterPlayerPrivilege(steamid, type, value, granted)
  steamid = BSU.ID64(steamid)

  -- incase this privilege is already registered, remove the old one
  BSU.RemovePlayerPrivilege(steamid, type, value)

  BSU.SQLInsert(BSU.SQL_PLAYER_PRIVILEGES,
    {
      steamid = steamid,
      type = type,
      value = value,
      granted = granted and 1 or 0
    }
  )
end

function BSU.RemoveGroupPrivilege(groupid, type, value)
  BSU.SQLDeleteByValues(BSU.SQL_GROUP_PRIVILEGES,
    {
      groupid = groupid,
      type = type,
      value = value
    }
  )
end

function BSU.RemovePlayerPrivilege(steamid, type, value)
  BSU.SQLDeleteByValues(BSU.SQL_PLAYER_PRIVILEGES,
    {
      steamid = BSU.ID64(steamid),
      type = type,
      value = value
    }
  )
end

function BSU.GetGroupWildcardPrivileges(groupid, type)
  return BSU.SQLParse(
    BSU.SQLQuery("SELECT * FROM '%s' WHERE groupid = %s AND type = %s AND value LIKE '%s'",
      BSU.EscOrNULL(BSU.SQL_GROUP_PRIVILEGES, true),
      BSU.EscOrNULL(groupid),
      BSU.EscOrNULL(type),
      "%*%"
    ) or {},
    BSU.SQL_GROUP_PRIVILEGES
  )
end

function BSU.GetPlayerWildcardPrivileges(steamid, type)
  return BSU.SQLParse(
    BSU.SQLQuery("SELECT * FROM '%s' WHERE steamid = %s AND type = %s AND value LIKE '%s'",
      BSU.EscOrNULL(BSU.SQL_PLAYER_PRIVILEGES, true),
      BSU.EscOrNULL(BSU.ID64(steamid)),
      BSU.EscOrNULL(type),
      "%*%"
    ) or {},
    BSU.SQL_PLAYER_PRIVILEGES
  )
end

-- returns bool if a group is granted the privilege (or nothing if the privilege is not registered)
function BSU.CheckGroupPrivilege(groupid, type, value)
  -- check for group privilege
  local priv = (BSU.SQLSelectByValues(BSU.SQL_GROUP_PRIVILEGES,
    {
      groupid = groupid,
      type = type,
      value = value
    }
  ) or {})[1]

  if priv then
    return priv.granted == 1
  else
    -- check wildcard privileges
    local wildcards = BSU.GetGroupWildcardPrivileges(groupid, type)
    table.sort(wildcards, function(a, b) return #a.value > #b.value end)
    
    for i = 1, #wildcards do
      local priv = wildcards[i]
      if string.find(value, string.Replace(priv.value, "*", "(.-)")) ~= nil then
        return priv.granted == 1
      end
    end

    -- check for privilege in inherited group
    local inherit = BSU.SQLSelectByValues(BSU.SQL_GROUPS, { id = groupid })[1].inherit
    
    if inherit then
      return BSU.CheckGroupPrivilege(inherit, type, value)
    end
  end
end

-- returns bool if the player is granted the privilege (or nothing if the privilege is not registered in the player's group)
function BSU.CheckPlayerPrivilege(steamid, type, value)
  steamid = BSU.ID64(steamid)

  -- check for player privilege
  local priv = (BSU.SQLSelectByValues(BSU.SQL_PLAYER_PRIVILEGES,
    {
      steamid = steamid,
      type = type,
      value = value
    }
  ) or {})[1]

  if priv then
    return priv.granted == 1
  else
    -- check wildcard privileges
    local wildcards = BSU.GetPlayerWildcardPrivileges(steamid, type)
    table.sort(wildcards, function(a, b) return #a.value > #b.value end)
    
    for i = 1, #wildcards do
      local priv = wildcards[i]
      if string.find(value, string.Replace(priv.value, "*", "(.-)")) ~= nil then
        return priv.granted == 1
      end
    end

    -- check for privilege in player's group
    local groupid = BSU.SQLSelectByValues(BSU.SQL_PLAYERS, { steamid = steamid })[1].groupid
    return BSU.CheckGroupPrivilege(groupid, type, value)
  end
end