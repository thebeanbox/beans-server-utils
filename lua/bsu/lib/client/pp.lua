-- lib/client/pp.lua

function BSU.SetPropPermission(steamid, permission)
	BSU.ClearPropPermission(steamid, permission) -- clear if already exists

	if permission <= 0 then return end -- no permission set

	BSU.SQLInsert(BSU.SQL_PP,
		{
			steamid = BSU.ID64(steamid),
			permission = permission
		}
	)
end

function BSU.ClearPropPermission(steamid)
	BSU.SQLDeleteByValues(BSU.SQL_PP, { steamid = BSU.ID64(steamid) })
end

function BSU.GetPropPermission(steamid)
	local query = BSU.SQLSelectByValues(BSU.SQL_PP, { steamid = BSU.ID64(steamid) })[1]
	return query and query.permission or 0
end

function BSU.CheckPropPermission(steamid, perm)
	local permission = BSU.GetPropPermission(steamid)
	return bit.band(permission, perm) == perm
end

-- returns a table of current players on the server the client has granted the permission to
function BSU.GetPropPermissionList(perm)
	local plys = {}
	for _, v in ipairs(player.GetHumans()) do
		if bit.band(BSU.GetPropPermission(v:GetSteamID64()), perm) == perm then
			table.insert(plys, v)
		end
	end
	return plys
end

-- send permission data to the server (takes a player, table of players, or nil for all current players)
function BSU.SendPropPermissionData(plys)
	if isentity(plys) then
		if not plys:IsPlayer() then return end
		plys = { plys }
	elseif istable(plys) then
		if next(plys) == nil then return end
	elseif plys == nil then
		plys = player.GetHumans()
	else
		return
	end

	local data = {}
	for _, v in ipairs(plys) do
		if v ~= LocalPlayer() and not v:IsBot() then -- ignore local player and bots
			table.insert(data, { v:UserID(), BSU.GetPropPermission(v:SteamID64()) })
		end
	end
	if next(data) == nil then return end

	net.Start("bsu_pp_data")
		net.WriteUInt(#data, 7) -- max of 127 entries (perfect because this is the max player limit excluding the local player)
		for i = 1, #data do
			net.WriteUInt(data[i][1], 15) -- userid range is 0-32767 (used instead of WriteEntity incase the player at the entindex is changed during transport)
			net.WriteUInt(data[i][2], 5)
		end
	net.SendToServer()
end

net.Receive("bsu_pp_data", function()
	local ply = Player(net.ReadUInt(15))
	if ply:IsPlayer() then
		BSU.SendPropPermissionData(ply)
	end
end)

-- utility functions for easily granting or revoking permissions

function BSU.GrantPropPermission(ply, perm)
	if ply ~= LocalPlayer() and not ply:IsBot() then -- ignore local player and bots
		local steamid = ply:SteamID64()
		local permission = BSU.GetPropPermission(steamid)
		BSU.SetPropPermission(steamid, bit.bor(permission, perm))
		BSU.SendPropPermissionData(ply)
	end
end

function BSU.RevokePropPermission(ply, perm)
	if ply ~= LocalPlayer() and not ply:IsBot() then -- ignore local player and bots
		local steamid = ply:SteamID64()
		local permission = BSU.GetPropPermission(steamid)
		BSU.SetPropPermission(steamid, bit.bxor(permission, perm))
		BSU.SendPropPermissionData(ply)
	end
end
