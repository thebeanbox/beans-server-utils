-- base/server/pp.lua

-- set the owner of map entities to the world
hook.Add("OnEntityCreated", "BSU_SetOwnerMapEntities", function(ent)
	if ent:IsValid() then
		timer.Simple(0, function() -- need to wait a tick for CreatedByMap to work correctly
			if ent:IsValid() and ent:CreatedByMap() then
				BSU.SetEntityOwner(ent, game.GetWorld())
			end
		end)
	end
end)

-- request data for this player from the clients
hook.Add("PlayerInitialSpawn", "BSU_RequestPropPermissionData", function(ply)
	BSU.RequestPropPermissionData(nil, ply)
end)

-- physgun checking
hook.Add("PhysgunPickup", "BSU_PhysgunPropPermission", function(ply, ent) return BSU.PlayerHasPropPermission(ply, ent, BSU.PP_PHYSGUN) end)

-- gravgun checking
local function checkGravgunPermission(ply, ent)
	return BSU.PlayerHasPropPermission(ply, ent, BSU.PP_GRAVGUN)
end

hook.Add("GravGunPunt", "BSU_GravgunPropPermission", checkGravgunPermission)
hook.Add("GravGunPickupAllowed", "BSU_GravgunPropPermission", checkGravgunPermission)

-- toolgun checking
hook.Add("CanTool", "BSU_ToolgunPropPermission", function(ply, trace) if IsValid(trace.Entity) then return BSU.PlayerHasPropPermission(ply, trace.Entity, BSU.PP_TOOLGUN) end end)
hook.Add("CanProperty", "BSU_ToolgunPropPermission", function(ply, _, ent) return BSU.PlayerHasPropPermission(ply, ent, BSU.PP_TOOLGUN) end)

-- use checking
local function checkUsePermission(ply, ent)
	return BSU.PlayerHasPropPermission(ply, ent, BSU.PP_USE)
end

hook.Add("PlayerUse", "BSU_UsePropPermission", checkUsePermission)
hook.Add("OnPlayerPhysicsPickup", "BSU_UsePropPermission", checkUsePermission)

-- damage checking
hook.Add("EntityTakeDamage", "BSU_DamagePropPermission", function(ent, dmg)
	if ent:IsPlayer() then return end

	local attacker = dmg:GetAttacker()
	if not attacker:IsValid() then return end

	-- option for entities on fire
	if attacker:GetClass() == "entityflame" then
		local owner = BSU.GetEntityOwner(ent)
		if owner and owner:IsWorld() or (owner:IsPlayer() and owner:GetInfoNum("bsu_allow_fire_damage", 0) ~= 0) then
			return
		end
	end

	if not attacker:IsPlayer() then attacker = BSU.GetEntityOwner(attacker) end

	if attacker == nil or attacker:IsWorld() or (attacker:IsPlayer() and BSU.PlayerHasPropPermission(attacker, ent, BSU.PP_DAMAGE) == false) then
		return true -- unlike the GravGun* and Can* hooks, this hook requires true to prevent it
	end
end)

-- override some functions to catch players spawning entities and properly set entity owner

local plyMeta = FindMetaTable("Player")

if plyMeta.AddCount then
	BSU._oldAddCount = BSU._oldAddCount or plyMeta.AddCount
	function plyMeta:AddCount(str, ent)
		if isentity(ent) and ent:IsValid() and not ent:IsPlayer() then
			BSU.SetEntityOwner(ent, self)
		end
		BSU._oldAddCount(self, str, ent)
	end
end

if plyMeta.AddCleanup then
	BSU._oldAddCleanup = BSU._oldAddCleanup or plyMeta.AddCleanup
	function plyMeta:AddCleanup(type, ent)
		if isentity(ent) and ent:IsValid() and not ent:IsPlayer() then
			BSU.SetEntityOwner(ent, self)
		end
		BSU._oldAddCleanup(self, type, ent)
	end
end

if cleanup.Add then
	BSU._oldCleanupAdd = BSU._oldCleanupAdd or cleanup.Add
	function cleanup.Add(ply, type, ent)
		if isentity(ply) and ply:IsPlayer() and isentity(ent) and ent:IsValid() and not ent:IsPlayer() then
			BSU.SetEntityOwner(ent, ply)
		end
		BSU._oldCleanupAdd(ply, type, ent)
	end
end

if cleanup.ReplaceEntity then
	BSU._oldCleanupReplaceEntity = BSU._oldCleanupReplaceEntity or cleanup.ReplaceEntity
	function cleanup.ReplaceEntity(from, to)
		if isentity(from) and from:IsValid() and not from:IsPlayer() and isentity(to) and to:IsValid() and not to:IsPlayer() then
			BSU.ReplaceEntityOwner(from, to)
		end
		BSU._oldCleanupReplaceEntity(from, to)
	end
end

if undo.ReplaceEntity then
	BSU._oldUndoReplaceEntity = BSU._oldUndoReplaceEntity or undo.ReplaceEntity
	function undo.ReplaceEntity(from, to)
		if isentity(from) and from:IsValid() and not from:IsPlayer() and isentity(to) and to:IsValid() and not to:IsPlayer() then
			BSU.ReplaceEntityOwner(from, to)
		end
		BSU._oldUndoReplaceEntity(from, to)
	end
end
