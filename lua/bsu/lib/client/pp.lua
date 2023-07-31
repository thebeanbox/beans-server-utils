-- lib/client/pp.lua

function BSU.SetPermission(steamid, permission)
	BSU.ClearPermission(steamid, permission) -- clear if already exists

	if permission <= 0 then return end -- no permission set

	BSU.SQLInsert(BSU.SQL_PP,
		{
			steamid = BSU.ID64(steamid),
			permission = permission
		}
	)
end

function BSU.ClearPermission(steamid)
	BSU.SQLDeleteByValues(BSU.SQL_PP, { steamid = BSU.ID64(steamid) })
end

function BSU.GetPermission(steamid)
	local query = BSU.SQLSelectByValues(BSU.SQL_PP, { steamid = BSU.ID64(steamid) })[1]
	return query and query.permission or 0
end

function BSU.CheckPermission(steamid, perm)
	local permission = BSU.GetPermission(steamid)
	return bit.band(permission, perm) == perm
end

-- returns a table of current players on the server the client has granted the permission to
function BSU.GetPermissionList(perm)
	local plys = {}
	for _, v in ipairs(player.GetHumans()) do
		if bit.band(BSU.GetPermission(v:GetSteamID64()), perm) == perm then
			table.insert(plys, v)
		end
	end
	return plys
end

-- send permission data to the server (takes a player, table of players, or nil for all current players)
function BSU.SendPermissions(plys)
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
			table.insert(data, { v:UserID(), BSU.GetPermission(v:SteamID64()) })
		end
	end
	if next(data) == nil then return end

	net.Start("bsu_perms")
		net.WriteUInt(#data, 7) -- max of 127 entries (perfect because this is the max player limit excluding the local player)
		for i = 1, #data do
			net.WriteUInt(data[i][1], 15) -- userid range is 0-32767 (used instead of WriteEntity incase the player at the entindex is changed during transport)
			net.WriteUInt(data[i][2], 5)
		end
	net.SendToServer()
end

net.Receive("bsu_perms", function()
	local ply = Player(net.ReadUInt(15))
	if ply:IsPlayer() then
		BSU.SendPermissions(ply)
	end
end)

-- utility functions for easily granting or revoking permissions

function BSU.GrantPermission(ply, perm)
	if ply ~= LocalPlayer() and not ply:IsBot() then -- ignore local player and bots
		local steamid = ply:SteamID64()
		local permission = BSU.GetPermission(steamid)
		BSU.SetPermission(steamid, bit.bor(permission, perm))
		BSU.SendPermissions(ply)
	end
end

function BSU.RevokePermission(ply, perm)
	if ply ~= LocalPlayer() and not ply:IsBot() then -- ignore local player and bots
		local steamid = ply:SteamID64()
		local permission = BSU.GetPermission(steamid)
		BSU.SetPermission(steamid, bit.bxor(permission, perm))
		BSU.SendPermissions(ply)
	end
end
