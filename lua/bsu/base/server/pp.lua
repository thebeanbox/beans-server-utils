-- base/server/pp.lua

local function CleanupProps(id)
	for _, ent in ipairs(BSU.GetOwnerEntities(id)) do
		ent:Remove()
	end
end

hook.Add("BSU_SteamIDBanned", "BSU_CleanupBannedPlayerProps", function(id)
	CleanupProps(id)
end)

hook.Add("BSU_IPBanned", "BSU_CleanupBannedPlayerProps", function(ip)
	local data = BSU.GetPlayerDataByIPAddress(ip) -- find any players associated with this ip
	for i = 1, #data do
		CleanupProps(data[i].steamid)
	end
end)

hook.Add("BSU_PlayerKicked", "BSU_CleanupKickedPlayerProps", function(ply)
	CleanupProps(ply:SteamID64())
end)

local cleanupTime = GetConVar("bsu_cleanup_time")

hook.Add("PlayerDisconnected", "BSU_HandleDisconnectedPlayerProps", function(ply)
	local id = ply:SteamID64()

	-- freeze props
	for _, ent in ipairs(BSU.GetOwnerEntities(id)) do
		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			local physObj = ent:GetPhysicsObjectNum(i)
			if IsValid(physObj) then
				physObj:EnableMotion(false)
			end
		end
	end

	-- cleanup after some time
	timer.Create("BSU_CleanupDisconnected_" .. id, cleanupTime:GetFloat(), 1, function()
		CleanupProps(id)
	end)

	-- clear permissions granted to disconnected players
	if not ply:IsBot() then
		BSU.ClearPermissionTo(id)
	end
end)

hook.Add("PlayerInitialSpawn", "BSU_RemoveCleanupDisconnected", function(ply)
	local id = ply:SteamID64()
	timer.Remove("BSU_CleanupDisconnected_" .. id) -- try remove the prop cleanup timer so they keep their props
end)

hook.Add("BSU_ClientReady", "BSU_InitPropProtection", function(ply)
	BSU.RequestPermissions(nil, ply) -- request all clients to send permission data for this player
	BSU.SendOwnerData(ply) -- send owner data to the client
end)

gameevent.Listen("player_changename")
hook.Add("player_changename", "BSU_UpdateOwnerName", function(data)
	BSU.SetOwnerInfo(Player(data.userid), "name", data.newname)
end)

-- physgun checking
local function CheckPhysgunPermission(ply, ent)
	return BSU.PlayerHasPermission(ply, ent, BSU.PP_PHYSGUN)
end

hook.Add("PhysgunPickup", "BSU_PhysgunPermission", CheckPhysgunPermission)
hook.Add("CanPlayerUnfreeze", "BSU_PhysgunPermission", CheckPhysgunPermission)

-- gravgun checking
local function CheckGravgunPermission(ply, ent)
	return BSU.PlayerHasPermission(ply, ent, BSU.PP_GRAVGUN)
end

hook.Add("GravGunPunt", "BSU_GravgunPermission", CheckGravgunPermission)
hook.Add("GravGunPickupAllowed", "BSU_GravgunPermission", CheckGravgunPermission)

-- toolgun checking
hook.Add("CanTool", "BSU_ToolgunPermission", function(ply, trace, toolmode) if IsValid(trace.Entity) then return BSU.PlayerHasPermission(ply, trace.Entity, BSU.PP_TOOLGUN, toolmode) end end)
hook.Add("CanProperty", "BSU_ToolgunPermission", function(ply, property, ent) return BSU.PlayerHasPermission(ply, ent, BSU.PP_TOOLGUN, property) end)
hook.Add("CanEditVariable", "BSU_ToolgunPermission", function(ent, ply, key, val, edit) return BSU.PlayerHasPermission(ply, ent, BSU.PP_TOOLGUN, key, val, edit) end)

-- use checking
local function CheckUsePermission(ply, ent)
	return BSU.PlayerHasPermission(ply, ent, BSU.PP_USE)
end

hook.Add("PlayerUse", "BSU_UsePermission", CheckUsePermission)
hook.Add("OnPlayerPhysicsPickup", "BSU_UsePermission", CheckUsePermission)
hook.Add("PlayerCanPickupItem", "BSU_UsePermission", CheckUsePermission)
hook.Add("PlayerCanPickupWeapon", "BSU_UsePermission", function(ply, ent)
	if not BSU.GetOwner(ent) then return end -- allow picking up ownerless weapons
	return CheckUsePermission(ply, ent)
end)

-- damage checking
hook.Add("EntityTakeDamage", "BSU_DamagePermission", function(ent, dmg)
	if ent:IsPlayer() then return end

	local attacker = dmg:GetAttacker()
	if not attacker:IsValid() then return end

	-- option for entities on fire
	if attacker:GetClass() == "entityflame" then
		local owner = BSU.GetOwner(ent)
		if owner and (owner:IsWorld() or (owner:IsPlayer() and owner:GetInfoNum("bsu_allow_fire_damage", 0) ~= 0)) then
			return
		end
	end

	if not attacker:IsPlayer() then attacker = BSU.GetOwner(attacker) end

	if not attacker then return true end

	if attacker:IsWorld() then -- let world-owned ents damage other world-owned ents
		local owner = BSU.GetOwner(ent)
		if owner and owner:IsWorld() then
			return
		end
	end

	if not attacker:IsValid() or BSU.PlayerHasPermission(attacker, ent, BSU.PP_DAMAGE) == false then
		return true -- unlike the GravGun* and Can* hooks, this hook requires true to prevent it
	end
end)

-- try set the owner of newly created entities
hook.Add("OnEntityCreated", "BSU_SetOwnerEntities", function(ent)
	if not ent:IsValid() then return end
	-- need to wait a tick for the entity to initialize and other hooks/detours to have a chance to set owner
	timer.Simple(0, function()
		if not ent:IsValid() or IsValid(BSU.GetOwner(ent)) then return end

		BSU.SetOwnerWorld(ent) -- default to world-owned

		if ent:CreatedByMap() then return end

		-- try fix the owner of engine entities not created by the map (this mostly fixes ents spawned by npcs or weapons)

		-- seems to always be a player, npc (zombie that dropped a headcrab) or NULL
		-- i don't think this will ever be nil, but just incase, it will fallback to NULL
		local owner = ent:GetInternalVariable("m_hOwnerEntity") or NULL
		-- sometimes is set to a weapon for projectile ents (has been seen to be nil)
		if owner == NULL then owner = ent:GetInternalVariable("m_hOwner") or NULL end
		if owner == NULL then return end

		if owner:IsPlayer() then
			BSU.SetOwner(ent, owner)
		else
			BSU.CopyOwner(owner, ent) -- try set the owner of the ent to the owner of it's internal owner
		end
	end)
end)

-- detour some functions to catch players spawning entities and properly set entity owner

local ENTITY = FindMetaTable("Entity")

BSU.DetourBefore(ENTITY, "SetOwner", "BSU_SetOwner", function(ent, owner)
	if IsValid(ent) and not ent:IsPlayer() and IsValid(owner) then
		BSU.CopyOwner(owner, ent)
	end
end)

local PLAYER = FindMetaTable("Player")

BSU.DetourBefore(PLAYER, "AddCount", "BSU_SetOwner", function(ply, _, ent)
	if IsValid(ent) then
		BSU.SetOwner(ent, ply)
	end
end)

BSU.DetourBefore(PLAYER, "AddCleanup", "BSU_SetOwner", function(ply, _, ent)
	if IsValid(ent) then
		BSU.SetOwner(ent, ply)
	end
end)

BSU.DetourBefore("cleanup.Add", "BSU_SetOwner", function(ply, _, ent)
	if IsValid(ply) and IsValid(ent) then
		BSU.SetOwner(ent, ply)
	end
end)

BSU.DetourWrap("cleanup.ReplaceEntity", "BSU_ReplaceOwner", function(args, action)
	if action then
		local from, to = args[1], args[2]
		if IsValid(from) and IsValid(to) then
			BSU.ReplaceOwner(from, to)
		end
	end
end)

BSU.DetourWrap("undo.ReplaceEntity", "BSU_ReplaceOwner", function(args, action)
	if action then
		local from, to = args[1], args[2]
		if IsValid(from) and IsValid(to) then
			BSU.ReplaceOwner(from, to)
		end
	end
end)

local currentUndo

BSU.DetourBefore("undo.Create", "BSU_SetOwner", function()
	currentUndo = { ents = {} }
end)

BSU.DetourBefore("undo.AddEntity", "BSU_SetOwner", function(ent)
	if currentUndo and IsValid(ent) then
		local ents = currentUndo.ents
		ents[#ents + 1] = ent
	end
end)

BSU.DetourBefore("undo.SetPlayer", "BSU_SetOwner", function(ply)
	if currentUndo and IsValid(ply) then
		currentUndo.owner = ply
	end
end)

BSU.DetourBefore("undo.Finish", "BSU_SetOwner", function()
	if currentUndo then
		local ply = currentUndo.owner
		if IsValid(ply) then
			local ents = currentUndo.ents
			for i = 1, #ents do
				local ent = ents[i]
				if IsValid(ent) then
					BSU.SetOwner(ent, ply)
				end
			end
		end
	end
	currentUndo = nil
end)
