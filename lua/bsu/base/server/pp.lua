-- base/server/pp.lua

-- sets the owner of map entities to the world (PLEASE FIND A METHOD THAT DOESN'T USE A TIMER)
timer.Simple(10, function()
  for _, ent in pairs(ents.FindByClass("*")) do
    if not ent:IsPlayer() and not BSU.GetEntityOwner(ent) then
      BSU.SetEntityOwner(ent, game.GetWorld())
    end
  end
end)

-- sets the owner of the entity when it spawns
local oldCleanupAdd = cleanup.Add
function cleanup.Add(ply, type, ent)
  BSU.SetEntityOwner(ent, ply)
  oldCleanupAdd(ply, type, ent)
end

local function notifyOwnership(ply, ent)
  BSU.ClientRPC(ply, "notification.AddLegacy", "You are now the owner of " .. tostring(ent), NOTIFY_GENERIC, 5)
end

local function checkPermission(ply, ent, perm)
  local owner = BSU.GetEntityOwner(ent)
  
  if not IsValid(owner) and owner ~= game.GetWorld() and not ent:IsPlayer() then
    local ownerID = BSU.GetEntityOwnerID(ent)
    
    if ownerID then
      if ply:SteamID() == ownerID then
        BSU.SetEntityOwner(ent, ply)
      end
    else
      BSU.SetEntityOwner(ent, ply)
      notifyOwnership(ply, ent)
    end
  end

  if ply:IsSuperAdmin() then return true end
  
  if not IsValid(owner) or owner == game.GetWorld() or (ply ~= owner and not BSU.PlayerIsGranted(ply, owner, perm)) then
    return false
  end
end

local function checkPhysgunPermission(ply, ent)
  return checkPermission(ply, ent, BSU.PP_PHYSGUN)
end

local function checkGravgunPermission(ply, ent)
  return checkPermission(ply, ent, BSU.PP_GRAVGUN)
end

local function checkToolgunPermission(ply, ent)
  return checkPermission(ply, ent, BSU.PP_TOOLGUN)
end

local function checkUsePermission(ply, ent)
  return checkPermission(ply, ent, BSU.PP_USE)
end

hook.Add("PhysgunPickup", "BSU_CheckPhysgunPermission", checkPhysgunPermission)
hook.Add("GravGunPunt", "BSU_CheckGravgunPermission", checkGravgunPermission)
hook.Add("GravGunPickupAllowed", "BSU_CheckGravgunPermission", checkGravgunPermission)
hook.Add("CanTool", "BSU_CheckToolgunPermission", function(ply, trace) return IsValid(trace.Entity) and checkToolgunPermission(ply, trace.Entity) end)
hook.Add("CanProperty", "BSU_CheckToolgunPermission", function(ply, _, ent) return checkToolgunPermission(ply, ent) end)
hook.Add("PlayerUse", "BSU_CheckUsePermission", checkUsePermission)

-- this fixes glitchy movement when grabbing players
hook.Add("OnPhysgunPickup", "BSU_PlayerPhysgunPickup", function(ply, ent)
  if ent:IsPlayer() then
    ent:SetMoveType(MOVETYPE_NONE)
  end
end)
hook.Add("PhysgunDrop", "BSU_PlayerPhysgunDrop", function(ply, ent)
  if ent:IsPlayer() then
    ent:SetMoveType(MOVETYPE_WALK)
  end
end)