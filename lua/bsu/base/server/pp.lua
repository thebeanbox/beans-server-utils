-- base/server/pp.lua

-- request a client's prop protection data after they authenticate
hook.Add("PlayerAuthed", "BSU_RequestPPData", function(ply) BSU.RequestPPData(ply) end)

-- initialize a client's prop protection data
local function initializePPData(_, ply)
  local plyID = ply:SteamID64()

  -- initialize an empty table for their data
  BSU._ppdata[plyID] = {}
  
  -- add the prop protection data
  -- structured like: PLAYER STEAM ID -> TARGET STEAM ID -> PERMISSION ID
  local len = net.ReadUInt(16)
  for i = 1, len do
    local steamid, permission = BSU.ID64(net.ReadString()), net.ReadUInt(3)

    -- make sure a table for the target exists
    if not BSU._ppdata[plyID][steamid] then BSU._ppdata[plyID][steamid] = {} end

    -- add the permission
    BSU._ppdata[plyID][steamid][permission] = true
  end
end

net.Receive("bsu_ppdata_init", initializePPData)

-- update a client's prop protection data (by adding/removing an entry)
local function updatePPData(_, ply)
  local plyID = ply:SteamID64()

  -- make sure a table for the player exists to avoid errors
  -- (table is possible to not exist if the client didn't have any prop protection data to send to the server)
  BSU._ppdata[plyID] = BSU._ppdata[plyID] or {}

  local method, steamid, permission = net.ReadBool(), BSU.ID64(net.ReadString()), net.ReadUInt(3)

  -- make sure a table for the target exists
  if not BSU._ppdata[plyID][steamid] then BSU._ppdata[plyID][steamid] = {} end

  -- either adds or removes the permission
  BSU._ppdata[plyID][steamid][permission] = method or nil

  -- remove these tables if they are empty
  if table.IsEmpty(BSU._ppdata[plyID][steamid]) then
    BSU._ppdata[plyID][steamid] = nil
    if table.IsEmpty(BSU._ppdata[plyID]) then
      BSU._ppdata[plyID] = nil
    end
  end
end

net.Receive("bsu_ppdata_update", updatePPData)

-- sets the owner of map entities to the world (internally just sets any entity with a N/A owner to World)
local function setOwnerMapEntities()
  for _, ent in pairs(ents.FindByClass("*")) do
    if not ent:IsPlayer() and ent ~= game.GetWorld() and not BSU.GetEntityOwner(ent) then
      BSU.SetEntityOwner(ent, game.GetWorld())
    end
  end
end

hook.Add("Initialize", "BSU_SetOwnerMapEntities", function() timer.Simple(10, setOwnerMapEntities) end)
hook.Add("PostCleanupMap", "BSU_SetOwnerMapEntities", setOwnerMapEntities)

-- sets the owner of the entity when it spawns
local oldCleanupAdd = cleanup.Add
function cleanup.Add(ply, type, ent)
  BSU.SetEntityOwner(ent, ply)
  ent:SetCustomCollisionCheck(true) -- needed for collision permission checking
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

  local owner
  local attacker = dmg:GetAttacker()
  
  if not IsValid(attacker) then
    return
  elseif attacker:IsPlayer() then -- set owner to the attacker
    owner = attacker
  else
    owner = BSU.GetEntityOwner(attacker) -- set owner to the attacker's owner
  end
  
  if not owner or (not IsValid(owner) and owner ~= game.GetWorld()) or BSU.CheckEntityPermission(owner, ent, BSU.PP_DAMAGE) == false then
    return true
  end
end)

-- "disabled this because it's buggy" -Bonyoze

-- no collision checking (ignores superadmin override for prop-to-prop collision)
--[[hook.Add("ShouldCollide", "BSU_CheckNoCollidePermission", function(ent1, ent2)
  if (not IsValid(ent1) or not IsValid(ent2)) or (ent1:IsPlayer() and ent2:IsPlayer()) then return end -- ignore if both are not valid or both are players

  local ply = ent1:IsPlayer() and ent1 or ent2:IsPlayer() and ent2
  
  if ply then -- one of the collided entities is a player
    local ent = not ent1:IsPlayer() and ent1 or ent2
    local plyID = ply:SteamID64()
    local entOwnerID = BSU.GetEntityOwnerID(ent)
    
    if ply:IsSuperAdmin() then return end

    if entOwnerID and plyID ~= entOwnerID and BSU.CheckPlayerHasPropPermission(entOwnerID, plyID, BSU.PP_NOCOLLIDE) ~= false then -- owner of the entity is a player, not the colliding player and the player being collided with doesn't allow collision
      return false
    end
  else
    local owner1ID = BSU.GetEntityOwnerID(ent1)
    local owner2ID = BSU.GetEntityOwnerID(ent2)

    if owner1ID and owner2ID and owner1ID ~= owner2ID then -- both entities are owned by different players
      local check1 = BSU.CheckPlayerHasPropPermission(owner1ID, owner2ID, BSU.PP_NOCOLLIDE, true)
      local check2 = BSU.CheckPlayerHasPropPermission(owner2ID, owner1ID, BSU.PP_NOCOLLIDE, true)
      
      if check1 ~= false or check2 ~= false then -- if atleast one of the owners doesn't allow collision then prevent collision
        return false
      end
    end
  end
end)]]