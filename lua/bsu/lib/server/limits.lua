-- lib/server/limits.lua

function BSU.RegisterGroupLimit(groupid, name, amount)
  name = string.lower(name)

  -- incase this limit is already registered, remove the old one
  BSU.RemoveGroupLimit(groupid, name)

  -- fix amount
  if not amount then
    local cvar = GetConVar("sbox_max" .. name)
    if cvar then amount = cvar:GetInt() end
  else
    amount = math.floor(amount)
  end

  BSU.SQLInsert(BSU.SQL_GROUP_LIMITS, {
    groupid = groupid,
    name = name,
    amount = amount
  })
end

function BSU.RegisterPlayerLimit(steamid, name, amount)
  steamid = BSU.ID64(steamid)
  name = string.lower(name)

  -- incase this limit is already registered, remove the old one
  BSU.RemovePlayerLimit(steamid, name)

  -- fix amount
  if not amount then
    local cvar = GetConVar("sbox_max" .. name)
    if cvar then amount = cvar:GetInt() end
  else
    amount = math.floor(amount)
  end

  BSU.SQLInsert(BSU.SQL_PLAYER_LIMITS, {
    steamid = steamid,
    name = name,
    amount = amount
  })
end

function BSU.RemoveGroupLimit(groupid, name)
  name = string.lower(name)

  BSU.SQLDeleteByValues(BSU.SQL_GROUP_LIMITS, {
    groupid = groupid,
    name = name
  })
end

function BSU.RemovePlayerLimit(steamid, name)
  steamid = BSU.ID64(steamid)
  name = string.lower(name)

  BSU.SQLDeleteByValues(BSU.SQL_PLAYER_LIMITS, {
    steamid = steamid,
    name = name
  })
end

function BSU.GetAllGroupLimits()
  return BSU.SQLSelectAll(BSU.SQL_GROUP_LIMITS) or {}
end

function BSU.GetAllPlayerLimits()
  return BSU.SQLSelectAll(BSU.SQL_PLAYER_LIMITS) or {}
end

-- returns the amount a group can spawn for a specific limit (or nothing if the limit is not registered) (this excludes the cvar 'sbox_max<limit name>')
function BSU.GetGroupLimit(groupid, name)
  name = string.lower(name)

  local limit = (BSU.SQLSelectByValues(BSU.SQL_GROUP_LIMITS,
    {
      groupid = groupid,
      name = name
    }
  ) or {})[1]

  if limit then
    return limit.amount
  else
    -- check for limit in inherited group
    local inherit = BSU.SQLSelectByValues(BSU.SQL_GROUPS, { id = groupid })[1].inherit
    
    if inherit then
      return BSU.GetGroupLimit(inherit, name)
    end
  end
end

-- returns the amount a player can spawn for a specific limit (or nothing if the limit is not registered) (this excludes the cvar 'sbox_max<limit name>')
function BSU.GetPlayerLimit(steamid, name)
  steamid = BSU.ID64(steamid)
  name = string.lower(name)

  local limit = (BSU.SQLSelectByValues(BSU.SQL_PLAYER_LIMITS,
    {
      steamid = steamid,
      name = name
    }
  ) or {})[1]
  
  if limit then
    return limit.amount
  else
    -- check for limit in player's group
    local groupid = BSU.SQLSelectByValues(BSU.SQL_PLAYERS, { steamid = steamid })[1].groupid
    return BSU.GetGroupLimit(groupid, name)
  end
end