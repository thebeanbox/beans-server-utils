-- lib/server/pdata.lua

function BSU.RegisterPData(steamid, key, value, network)
	steamid = BSU.ID64(steamid)

	BSU.RemovePData(steamid, key)

	BSU.SQLInsert(BSU.SQL_PDATA, {
		steamid = steamid,
		key = key,
		value = value,
		network = network and 1 or 0
	})
end

function BSU.RemovePData(steamid, key)
	BSU.SQLDeleteByValues(BSU.SQL_PDATA, { steamid = BSU.ID64(steamid), key = key })
end

function BSU.GetPDataBySteamID(steamid, key)
	local query = BSU.SQLSelectByValues(BSU.SQL_PDATA, { steamid = BSU.ID64(steamid), key = key })[1]
	if query then return query.value end
end

function BSU.GetAllPDataBySteamID(steamid, network)
	local query = BSU.SQLSelectByValues(BSU.SQL_PDATA, { steamid = steamid })
	local data = {}

	for i = 1, #query do
		local entry = query[i]
		if network ~= nil and entry.network == (network and 1 or 0) then continue end
		data[entry.key] = entry.value
	end

	return data
end

-- adds pdata key to a player (or overwrites an existing pdata key with a new value)
function BSU.SetPData(ply, key, value, network)
	key = tostring(key)
	value = tostring(value)

	BSU.RegisterPData(ply:SteamID64(), key, value, network)
	ply:SetNW2String("bsu_" .. key, network and value or nil)
end

-- clears pdata key on a player (or does nothing if it's not set)
function BSU.ClearPData(ply, key)
	key = tostring(key)

	if not BSU.GetPData(ply, key) then return end

	BSU.RemovePData(ply:SteamID64(), key)
	ply:SetNW2String("bsu_" .. key, nil)
end

-- gets a pdata value on a player (or nothing if it's not set)
function BSU.GetPData(ply, key)
	return BSU.GetPDataBySteamID(ply:SteamID64(), key)
end

-- gets a table of all the pdata on a player
-- optionally get only networked data (network = true)
-- optionally get only non-networked data (network = false)
-- (leave network unset to get all data)
function BSU.GetAllPData(ply, network)
	return BSU.GetAllPDataBySteamID(ply:SteamID64(), network)
end