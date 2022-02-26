-- lib/server/pp.lua

function BSU.RequestPPClientData(plys, steamids)
  if not istable(steamids) and isstring(steamids) then steamids = { steamids } end
  BSU.ClientRPC(plys, "BSU.SendPPClientData", steamids)
end

-- returns a list of steam 64 bit ids this player has enabled this permission to
function BSU.GetPlayerPermissionList(steamid, perm)
  steamid = BSU.ID64(steamid)

  if not BSU.PPClientData[steamid] then return {} end

  local ids = {}
  for k, v in pairs(BSU.PPClientData[steamid]) do
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

  return BSU.PPClientData[target] and BSU.PPClientData[target][ply] and BSU.PPClientData[target][ply][perm] ~= nil or false
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
local function checkWorldPermission(perm)
  return perm == BSU.PP_GRAVGUN or perm == BSU.PP_USE or perm == BSU.PP_DAMAGE
end

-- check if player has been set a permission by the target player (true or nil if player has permission, false if no permission) (returns nil incase another hook or addon wants to check)
function BSU.CheckPlayerPermission(ply, target, perm, ignoreSuperAdmin)
  if not ignoreSuperAdmin and ply:IsSuperAdmin() then return true end

  if target then
    if target == game.GetWorld() then
      if not checkWorldPermission(perm) then
        return false
      end
    elseif target:IsPlayer() then
      if ply:SteamID64() ~= target:SteamID64() and not BSU.CheckPlayerHasPropPermission(ply:SteamID64(), target:SteamID64(), perm) then
        return false
      end
    end
  end
end

-- check if player has permission over an entity (true or nil if player has permission, false if no permission) (returns nil incase another hook or addon wants to check)
function BSU.CheckEntityPermission(ply, ent, perm, ignoreSuperAdmin)
  local owner = BSU.GetEntityOwner(ent)
  local ownerID = BSU.GetEntityOwnerID(ent)

  if not ent:IsPlayer() then
    if not owner then -- owner is N/A
      return
    elseif not IsValid(owner) and owner ~= game.GetWorld() then -- owner is a disconnected player
      if ply:SteamID64() == ownerID then -- give back ownership
        BSU.SetEntityOwner(ent, ply)
      end
    end
  end

  return BSU.CheckPlayerPermission(ply, owner, perm, ignoreSuperAdmin)
end