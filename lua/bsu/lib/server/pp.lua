-- lib/server/pp.lua

-- holds prop protection perms
BSU._perms = BSU._perms or {}

function BSU.SetPlayerPropPermission(ply, target, perm)
	if not ply:IsPlayer() then error("Player is invalid") end
	if not target:IsPlayer() then error("Target is invalid") end

	if perm and perm > 0 then
		if not BSU._perms[target] then BSU._perms[target] = {} end
		BSU._perms[target][ply] = perm
	elseif BSU._perms[target] then
		BSU._perms[target][ply] = nil
		if next(BSU._perms[target]) == nil then BSU._perms[target] = nil end
	end
end

function BSU.GetPlayerPropPermission(ply, target)
	if not ply:IsPlayer() then error("Player is invalid") end
	if not target:IsPlayer() then error("Target is invalid") end

	local permission = BSU._perms[ply] and BSU._perms[ply][target] and BSU._perms[ply][target]
	return permission or 0
end

-- returns bool if player has permission by the target player
function BSU.CheckPlayerPropPermission(ply, target, perm)
	local permission = BSU.GetPlayerPropPermission(ply, target)
	return bit.band(permission, perm) == perm
end

-- returns a table of current players on the server the player has granted the permission to
function BSU.GetPlayerPropPermissionList(ply, perm)
	if not ply:IsPlayer() then error("Player is invalid") end

	local plys = {}
	for k, v in pairs(BSU._perms) do
		local permission = v[ply]
		if permission and bit.band(permission, perm) == perm then
			table.insert(plys, k)
		end
	end
	return plys
end

local worldPermission = BSU.PP_GRAVGUN + BSU.PP_USE + BSU.PP_DAMAGE

-- returns bool if players have permission on the world
function BSU.CheckWorldPropPermission(perm)
	return bit.band(worldPermission, perm) == perm
end

function BSU.SetEntityOwnerless(ent)
	if not ent:IsValid() or ent:IsPlayer() then error("Entity is invalid") end

	ent:SetNWEntity("BSU_Owner", nil)
	ent:SetNWEntity("BSU_OwnerName", nil)
	ent:SetNWEntity("BSU_OwnerID", nil)
end

function BSU.SetEntityOwner(ent, owner)
	if ent:IsPlayer() then error("Entity is invalid") end
	if not owner:IsPlayer() and not owner:IsWorld() then error("Owner entity is invalid") end

	ent:SetNWEntity("BSU_Owner", owner)
	-- this is so we can still get the name and id of the player after they leave the server
	ent:SetNWString("BSU_OwnerName", not owner:IsWorld() and owner:Nick() or "World") -- this is used for the hud
	ent:SetNWString("BSU_OwnerID", not owner:IsWorld() and owner:SteamID64() or nil) -- this is used so we can identify the owner and give back ownership if they disconnect and then reconnect
end

function BSU.ReplaceEntityOwner(from, to)
	if not from:IsValid() or from:IsPlayer() then error("From entity is invalid") end
	if not to:IsValid() or to:IsPlayer() then error("To entity is invalid") end

	to:SetNWEntity("BSU_Owner", from:GetNWEntity("BSU_Owner"))
	to:SetNWString("BSU_OwnerName", from:GetNWString("BSU_OwnerName"))
	to:SetNWString("BSU_OwnerID", from:GetNWString("BSU_OwnerID"))

	from:SetNWEntity("BSU_Owner", nil)
	from:SetNWEntity("BSU_OwnerName", nil)
	from:SetNWEntity("BSU_OwnerID", nil)
end

-- utility function for hooks to know if a player has permission over an entity
-- can return the following:
--  true  - player has permission (player is superadmin and must have permission)
--  nil   - player has permission (nil so the hook lets another addon can decide if the player should have permission)
--  false - player doesn't have permission
function BSU.PlayerHasPropPermission(ply, ent, perm)
	if ply:IsSuperAdmin() then return true end

	local owner = BSU.GetEntityOwner(ent)
	if owner then ent = owner end

	if ply == ent then return end

	if ent:IsPlayer() then
		if BSU.CheckPlayerPropPermission(ply, ent, perm) ~= false then return end
	elseif ent:IsWorld() then
		if BSU.CheckWorldPropPermission(perm) ~= false then return end
	end

	return false
end

function BSU.RequestPropPermissionData(plys, target)
	net.Start("bsu_pp_data")
		net.WriteUInt(target:UserID(), 15)
	if plys then
		net.Send(plys)
	else
		net.Broadcast()
	end
end

net.Receive("bsu_pp_data", function(_, ply)
	local total = net.ReadUInt(7)
	for _ = 1, total do
		local target = Player(net.ReadUInt(15))
		local perm = net.ReadUInt(5)
		if target:IsPlayer() then
			BSU.SetPlayerPropPermission(ply, target, perm)
		end
	end
end)
