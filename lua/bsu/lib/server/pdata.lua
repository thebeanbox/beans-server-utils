-- lib/server/pdata.lua

function BSU.RegisterPData(steamid, key, value, network)
  steamid = BSU.ID64(steamid)

  BSU.RemovePData(steamid, key)

  BSU.SQLInsert(BSU.SQL_PDATA, {
    steamid = steamid,
    key = key,
    value = value,
    network = network and 0 or 1
  })
end

function BSU.RemovePData(steamid, key)
  BSU.SQLDeleteByValues(BSU.SQL_PDATA, { steamid = BSU.ID64(steamid), key = key })
end

function BSU.GetPDataBySteamID(steamid, key)
  local query = BSU.SQLSelectByValues(BSU.SQL_PDATA, { steamid = BSU.ID64(steamid), key = key })[1]
  if query then return query.value end
end

function BSU.GetAllPDataBySteamID(steamid)
  local query = BSU.SQLSelectByValues(BSU.SQL_PDATA, { steamid = steamid })
  local data = {}

  for i = 1, #query do
    local entry = query[i]
    data[entry.key] = entry.value
  end

  return data
end

-- adds pdata key to a player (or overwrites an existing pdata key with a new value)
function BSU.SetPData(ply, key, value, network)
  key = tostring(key)
  value = tostring(value)

  BSU.RegisterPData(ply:SteamID64(), key, value, network)
  if network then
    ply:SetNW2String("BSU_PDATA_" .. key, value)
  end
end

-- clears pdata key on a player (or does nothing if it's not set)
function BSU.ClearPData(ply, key)
  key = tostring(key)

  if not BSU.GetPData(ply, key) then return end

  BSU.RemovePData(ply:SteamID64(), key)
  ply:SetNW2String("BSU_PDATA_" .. key, nil)
end

-- gets a pdata value on a player (or nothing if it's not set)
function BSU.GetPData(ply, key)
  return BSU.GetPDataBySteamID(ply:SteamID64(), key)
end

-- gets a table of all the pdata on a player
function BSU.GetAllPData(ply)
  return BSU.GetAllPDataBySteamID(ply:SteamID64())
end