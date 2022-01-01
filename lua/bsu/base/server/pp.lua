-- base/server/pp.lua

-- sets the owner of map entities to the world (internally just sets any entity with a N/A owner to World)
local function setOwnerMapEntities()
  for _, ent in pairs(ents.FindByClass("*")) do
    if not ent:IsPlayer() and ent ~= game.GetWorld() and not BSU.GetEntityOwner(ent) then
      BSU.SetEntityOwner(ent, game.GetWorld())
    end
  end
end

hook.Add("Initialize", "BSU_SetOwnerMapEntities", function()
  timer.Simple(10, setOwnerMapEntities)
end)
hook.Add("PostCleanupMap", "BSU_SetOwnerMapEntities", setOwnerMapEntities)

-- sets the owner of the entity when it spawns
local oldCleanupAdd = cleanup.Add
function cleanup.Add(ply, type, ent)
  BSU.SetEntityOwner(ent, ply)
  oldCleanupAdd(ply, type, ent)
end

-- physgun checking
hook.Add("PhysgunPickup", "BSU_CheckPhysgunPermission", function(ply, ent) return BSU.CheckEntityPermission(ply, ent, BSU.PP_PHYSGUN) end)

-- gravgun checking
local function checkGravgunPermission(ply, ent)
  return BSU.CheckEntityPermission(ply, ent, BSU.PP_GRAVGUN)
end

hook.Add("GravGunPunt", "BSU_CheckGravgunPermission", checkGravgunPermission)
hook.Add("GravGunPickupAllowed", "BSU_CheckGravgunPermission", checkGravgunPermission)

-- toolgun checking
hook.Add("CanTool", "BSU_CheckToolgunPermission", function(ply, trace) if IsValid(trace.Entity) then return BSU.CheckEntityPermission(ply, trace.Entity, BSU.PP_TOOLGUN) end end)
hook.Add("CanProperty", "BSU_CheckToolgunPermission", function(ply, _, ent) return BSU.CheckEntityPermission(ply, ent, BSU.PP_TOOLGUN) end)

-- use checking
local function checkUsePermission(ply, ent)
  return BSU.CheckEntityPermission(ply, ent, BSU.PP_USE)
end

hook.Add("PlayerUse", "BSU_CheckUsePermission", checkUsePermission)
hook.Add("OnPlayerPhysicsPickup", "BSU_CheckUsePermission", checkUsePermission)

-- damage checking
hook.Add("EntityTakeDamage", "BSU_CheckDamagePermission", function(ent, dmg)
  if ent:IsPlayer() then return end

  local ply
  local attacker = dmg:GetAttacker()

  if not IsValid(attacker) then
    return
  elseif attacker:IsPlayer() then -- set ply to the attacker
    ply = attacker
  else
    ply = BSU.GetEntityOwner(attacker) -- set ply to the attacker's owner
  end
  
  if not ply or (not IsValid(ply) and ply ~= game.GetWorld()) or BSU.CheckEntityPermission(ply, ent, BSU.PP_DAMAGE) == false then
    return true
  end
end)