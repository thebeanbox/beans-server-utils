-- base/server/pp.lua

-- sets the owner of map entities to the world
hook.Add("Initialize", "BSU_SetOwnerMapEntities", function()
  timer.Simple(10, function()
    for _, ent in pairs(ents.FindByClass("*")) do
      if not ent:IsPlayer() and ent ~= game.GetWorld() and not BSU.GetEntityOwner(ent) then
        BSU.SetEntityOwner(ent, game.GetWorld())
      end
    end
  end)
end)

-- sets the owner of the entity when it spawns
local oldCleanupAdd = cleanup.Add
function cleanup.Add(ply, type, ent)
  BSU.SetEntityOwner(ent, ply)
  oldCleanupAdd(ply, type, ent)
end

local function checkWorldPermission(perm)
  return perm == BSU.PP_GRAVGUN or perm == BSU.PP_USE or perm == BSU.PP_DAMAGE
end

local function checkPermission(ply, ent, perm)
  local owner = BSU.GetEntityOwner(ent)
  local ownerID = BSU.GetEntityOwnerID(ent)

  if not owner then -- owner is N/A
    return
  elseif not IsValid(owner) and owner ~= game.GetWorld() then -- owner is a disconnected player
    if ply:SteamID() == ownerID then -- give back ownership
      BSU.SetEntityOwner(ent, ply)
    end
  end
  
  if ply:IsSuperAdmin() then return true end

  if owner == game.GetWorld() then
    if not checkWorldPermission(perm) then
      return false
    end
  elseif owner:IsPlayer() then
    if ply:SteamID() ~= ownerID and not BSU.CheckPlayerHasPermission(ply:SteamID64(), BSU.ID64(ownerID), perm) then
      return false
    end
  end
end

-- physgun checking
hook.Add("PhysgunPickup", "BSU_CheckPhysgunPermission", function(ply, ent) return checkPermission(ply, ent, BSU.PP_PHYSGUN) end)

-- gravgun checking
local function checkGravgunPermission(ply, ent)
  return checkPermission(ply, ent, BSU.PP_GRAVGUN)
end

hook.Add("GravGunPunt", "BSU_CheckGravgunPermission", checkGravgunPermission)
hook.Add("GravGunPickupAllowed", "BSU_CheckGravgunPermission", checkGravgunPermission)

-- toolgun checking
hook.Add("CanTool", "BSU_CheckToolgunPermission", function(ply, trace) if IsValid(trace.Entity) then return checkPermission(ply, trace.Entity, BSU.PP_TOOLGUN) end end)
hook.Add("CanProperty", "BSU_CheckToolgunPermission", function(ply, _, ent) return checkPermission(ply, ent, BSU.PP_TOOLGUN) end)

-- use checking
local function checkUsePermission(ply, ent)
  return checkPermission(ply, ent, BSU.PP_USE)
end

hook.Add("PlayerUse", "BSU_CheckUsePermission", checkUsePermission)
hook.Add("OnPlayerPhysicsPickup", "BSU_CheckUsePermission", checkUsePermission)

-- damage checking
hook.Add("EntityTakeDamage", "BSU_CheckDamagePermission", function(ent, dmg)
  local ply
  local attacker = dmg:GetAttacker()

  if not IsValid(attacker) then
    return
  elseif attacker:IsPlayer() then -- set ply to the attacker
    ply = attacker
  else
    ply = BSU.GetEntityOwner(attacker) -- set ply to the attacker's owner
  end
  
  if (ply == game.GetWorld() and not checkWorldPermission(BSU.PP_DAMAGE)) or (not IsValid(ply) or checkPermission(ply, ent, BSU.PP_DAMAGE) == false) then
    return true
  end
end)

-- these hooks fix glitchy movement when grabbing players
hook.Add("OnPhysgunPickup", "BSU_PlayerPhysgunPickup", function(ply, ent)
  if ent:IsPlayer() then ent:SetMoveType(MOVETYPE_NONE) end
end)

hook.Add("PhysgunDrop", "BSU_PlayerPhysgunDrop", function(ply, ent)
  if ent:IsPlayer() then ent:SetMoveType(MOVETYPE_WALK) end
end)