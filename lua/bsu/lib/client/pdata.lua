-- lib/client/pdata.lua

-- gets a pdata value on a player (or default if it's not set)
function BSU.GetPData(ply, key, default)
	local val = (ply or LocalPlayer()):GetNW2String("bsu_" .. key, false)
	if val then return val end
	return default
end

-- gets a pdata value on a player and attempts to convert it to a number (or default if it fails to convert)
function BSU.GetPDataNumber(ply, key, default)
	return tonumber(BSU.GetPData(ply, key, default)) or default
end