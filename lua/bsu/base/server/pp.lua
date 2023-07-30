-- base/server/pp.lua

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
		if owner and (owner:IsWorld() or (owner:IsPlayer() and owner:GetInfoNum("bsu_allow_fire_damage", 0) ~= 0)) then
			return
		end
	end

	if not attacker:IsPlayer() then attacker = BSU.GetEntityOwner(attacker) end

	if attacker == nil or attacker:IsWorld() or not attacker:IsValid() or BSU.PlayerHasPermission(attacker, ent, BSU.PP_DAMAGE) == false then
		return true -- unlike the GravGun* and Can* hooks, this hook requires true to prevent it
	end
end)

-- try set the owner of newly created entities
hook.Add("OnEntityCreated", "BSU_SetOwnerMapEntities", function(ent)
	if ent:IsValid() then
		timer.Simple(0, function() -- need to wait a tick to ensure some data to be available
			if ent:IsValid() then
				if ent:CreatedByMap() then
					BSU.SetEntityOwner(ent, game.GetWorld())
				else
					local owner = ent:GetInternalVariable("m_hOwnerEntity") -- seems to always be a player or NULL entity
					if not owner:IsPlayer() then owner = ent:GetInternalVariable("m_hOwner") end
					if owner and owner:IsPlayer() then
						BSU.SetEntityOwner(ent, owner)
					end
				end
			end
		end)
	end
end)

-- override some functions to catch players spawning entities and properly set entity owner

local plyMeta = FindMetaTable("Player")

BSU._oldAddCount = BSU._oldAddCount or plyMeta.AddCount
function plyMeta:AddCount(str, ent, ...)
	if IsValid(ent) then
		BSU.SetEntityOwner(ent, self)
	end
	return BSU._oldAddCount(self, str, ent, ...)
end

BSU._oldAddCleanup = BSU._oldAddCleanup or plyMeta.AddCleanup
function plyMeta:AddCleanup(type, ent, ...)
	if IsValid(ent) then
		BSU.SetEntityOwner(ent, self)
	end
	return BSU._oldAddCleanup(self, type, ent, ...)
end

BSU._oldCleanupAdd = BSU._oldCleanupAdd or cleanup.Add
function cleanup.Add(ply, type, ent, ...)
	if IsValid(ply) and IsValid(ent) then
		BSU.SetEntityOwner(ent, ply)
	end
	return BSU._oldCleanupAdd(ply, type, ent, ...)
end

BSU._oldCleanupReplaceEntity = BSU._oldCleanupReplaceEntity or cleanup.ReplaceEntity
function cleanup.ReplaceEntity(from, to, ...)
	local ret = { BSU._oldCleanupReplaceEntity(from, to, ...) }
	if ret[1] and IsValid(from) and IsValid(to) then
		BSU.ReplaceEntityOwner(from, to)
	end
	return unpack(ret)
end

BSU._oldUndoReplaceEntity = BSU._oldUndoReplaceEntity or undo.ReplaceEntity
function undo.ReplaceEntity(from, to, ...)
	local ret = { BSU._oldUndoReplaceEntity(from, to, ...) }
	if ret[1] and IsValid(from) and IsValid(to) then
		BSU.ReplaceEntityOwner(from, to)
	end
	return unpack(ret)
end

local currentUndo

BSU._oldUndoCreate = BSU._oldUndoCreate or undo.Create
function undo.Create(...)
	currentUndo = { ents = {} }
	return BSU._oldUndoCreate(...)
end

BSU._oldUndoAddEntity = BSU._oldUndoAddEntity or undo.AddEntity
function undo.AddEntity(ent, ...)
	if currentUndo and IsValid(ent) then
		table.insert(currentUndo.ents, ent)
	end
	return BSU._oldUndoAddEntity(ent, ...)
end

BSU._oldUndoSetPlayer = BSU._oldUndoSetPlayer or undo.SetPlayer
function undo.SetPlayer(ply, ...)
	if currentUndo and IsValid(ply) then
		currentUndo.owner = ply
	end
	return BSU._oldUndoSetPlayer(ply, ...)
end

BSU._oldUndoFinish = BSU._oldUndoFinish or undo.Finish
function undo.Finish(...)
	if currentUndo then
		local ply = currentUndo.owner
		if IsValid(ply) then
			for _, ent in ipairs(currentUndo.ents) do
				if IsValid(ent) then
					BSU.SetEntityOwner(ent, ply)
				end
			end
		end
	end
	currentUndo = nil
	return BSU._oldUndoFinish(...)
end
