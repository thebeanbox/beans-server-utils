-- lib/client/pdata.lua

local playerData = {}

net.Receive("bsu_pdata", function()
	local ind = net.ReadUInt(8)

	local data = playerData[ind]
	if not data then
		data = {}
		playerData[ind] = data
	end

	local key = net.ReadString()

	if net.ReadBool() then
		data[key] = net.ReadString()
	else
		data[key] = nil
	end
end)

hook.Add("EntityRemoved", "BSU_CleanPData", function(ent, fullUpdate)
	if fullUpdate then return end
	local ind = ent:EntIndex()
	if playerData[ind] then
		playerData[ind] = nil
	end
end)

-- gets a pdata value on a player (or default if it's not set)
function BSU.GetPData(ply, key, default)
	local data = playerData[ply:EntIndex()]
	return data and data[key] or default -- Lua ternary magic
end

-- gets a pdata value on a player and attempts to convert it to a number (or default if it fails to convert)
function BSU.GetPDataNumber(ply, key, default)
	return tonumber(BSU.GetPData(ply, key, default)) or default
end
