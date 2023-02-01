-- lib/server/pp.lua

-- holds prop protection data from the clients
BSU._ppdata = BSU._ppdata or {}

function BSU.RequestPPData(plys, steamids)
	if not istable(steamids) and isstring(steamids) then steamids = { steamids } end
	BSU.ClientRPC(plys, "BSU.SendPPData", steamids)
end

-- returns a list of steam 64 bit ids this player has enabled this permission to
function BSU.GetPlayerPermissionList(steamid, perm)
	steamid = BSU.ID64(steamid)

	if not BSU._ppdata[steamid] then return {} end

	local ids = {}
	for k, v in pairs(BSU._ppdata[steamid]) do
		if v[perm] then
			table.insert(ids, k)
		end
	end

	return ids
end

-- returns bool if this player has been set a specific permission by the target player
function BSU.CheckPlayerHasPropPermission(ply, target, perm)
	ply = BSU.ID64(ply)
	target = BSU.ID64(target)

	return BSU._ppdata[target] and BSU._ppdata[target][ply] and BSU._ppdata[target][ply][perm] ~= nil or false
end

function BSU.SetEntityOwnerless(ent)
	if not IsValid(ent) then return error("Entity is invalid") end
	ent:SetNW2Entity("BSU_Owner", nil)
	ent:SetNW2Entity("BSU_OwnerName", nil)
	ent:SetNW2Entity("BSU_OwnerID", nil)
end

function BSU.SetEntityOwner(ent, owner)
	if not IsValid(ent) then return error("Entity is invalid") end
	if not IsValid(ent) and owner ~= game.GetWorld() then return error("Owner entity is invalid") end
	if ent:IsPlayer() then return error("Entity cannot be a player") end
	if not owner:IsPlayer() and owner ~= game.GetWorld() then return error("Owner entity must be a player or the world") end

	ent:SetNW2Entity("BSU_Owner", owner)
	-- this is so we can still get the name and id of the player after they leave the server
	ent:SetNW2String("BSU_OwnerName", owner ~= game.GetWorld() and owner:Nick() or "World") -- this is used for the hud
	ent:SetNW2String("BSU_OwnerID", owner ~= game.GetWorld() and owner:SteamID64() or nil) -- this is used so we can identify the owner and give back ownership if they disconnect and then reconnect
end

-- allow gravgun, use and damage for world props
function BSU.CheckWorldPermission(ply, perm, ignoreSuperAdmin)
	if not ignoreSuperAdmin and ply:IsSuperAdmin() then return true end
	return perm == BSU.PP_GRAVGUN or perm == BSU.PP_USE or perm == BSU.PP_DAMAGE
end

-- check if player has been set a permission by the target player
-- Returns:
-- true  - player must have permission (if ignoreSuperAdmin is false and player is superadmin)
-- nil   - player has permission (nil incase another addon wants to check when used in a hook)
-- false - player doesn't have permission
function BSU.CheckPlayerPermission(ply, target, perm, ignoreSuperAdmin)
	if not ignoreSuperAdmin and ply:IsSuperAdmin() then return true end

	if target then
		if target == game.GetWorld() then
			if not BSU.CheckWorldPermission(ply, perm, ignoreSuperAdmin) then
				return false
			end
		elseif target:IsPlayer() then
			if ply:SteamID64() ~= target:SteamID64() and not BSU.CheckPlayerHasPropPermission(ply:SteamID64(), target:SteamID64(), perm) then
				return false
			end
		end
	end
end

-- returns true or false if player has permission from the target player
function BSU.PlayerHasPermission(ply, target, perm, ignoreSuperAdmin)
	return BSU.CheckPlayerPermission(ply, target, perm, ignoreSuperAdmin) ~= false
end

-- check if player has permission over an entity
-- Returns:
-- true  - player must have permission (if ignoreSuperAdmin is false and player is superadmin)
-- nil   - player has permission (nil incase another addon wants to check when used in a hook)
-- false - player doesn't have permission
function BSU.CheckEntityPermission(ply, ent, perm, ignoreSuperAdmin)
	if ent:IsPlayer() then
		return BSU.CheckPlayerPermission(ply, ent, perm, ignoreSuperAdmin)
	end

	local owner = BSU.GetEntityOwner(ent)
	local ownerID = BSU.GetEntityOwnerID(ent)

	-- owner is N/A
	if not owner then return end

	-- owner is a disconnected player
	if not IsValid(owner) and owner ~= game.GetWorld() and ply:SteamID64() == ownerID then
		BSU.SetEntityOwner(ent, ply) -- give back ownership
	end

	return BSU.CheckPlayerPermission(ply, owner, perm, ignoreSuperAdmin)
end

-- returns true or false if player has permission over an entity
function BSU.PlayerHasEntityPermission(ply, ent, perm, ignoreSuperAdmin)
	return BSU.CheckEntityPermission(ply, ent, perm, ignoreSuperAdmin) ~= false
end