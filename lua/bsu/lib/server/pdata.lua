-- lib/server/pdata.lua

function BSU.RegisterPData(steamid, key, value, network)
  steamid = BSU.ID64(steamid)

  BSU.RemovePData(steamid, key)

  BSU.SQLInsert(BSU.SQL_PDATA, {
    steamid = steamid,
    key = key,
    value = value
    network = network and 0 or 1
  })
end

function BSU.RemovePData(steamid, key)
  BSU.SQLDeleteByValues(BSU.SQL_PDATA, {
    steamid = BSU.ID64(steamid),
    key = key
  })
end

function BSU.GetPDataBySteamID(steamid, key)
  return BSU.SelectByValues(BSU.SQL_PDATA, { steamid = BSU.ID64(steamid), key = key })[1]
end

function BSU.GetPData(ply, key)
  return BSU.GetPDataBySteamID(ply:SteamID64(), key)
end