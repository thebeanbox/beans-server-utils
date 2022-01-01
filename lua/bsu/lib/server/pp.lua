-- lib/server/pp.lua

function BSU.RegisterPlayerPermission(granter, receiver, permission)
  BSU.SQLInsert(BSU.SQL_PP_GRANTS,
    {
      granter = BSU.ID64(granter),
      receiver = BSU.ID64(receiver),
      permission = permission
    }
  )
end

function BSU.RemovePlayerPermission(granter, receiver, permission)
  BSU.SQLDeleteByValues(BSU.SQL_PP_GRANTS, { granter = BSU.ID64(granter), receiver = BSU.ID64(receiver), permission = permission })
end

function BSU.GetPlayerPermissions(granter, receiver)
  local query = BSU.SQLSelectByValues(BSU.SQL_PP_GRANTS, { granter = BSU.ID64(granter), receiver = BSU.ID64(receiver) }) or {}

  local perms = {}
  for _, v in ipairs(query) do
    table.insert(perms, v.permission)
  end
  return perms
end

-- returns a list of steam 64 bit ids this player has granted a specific permission
function BSU.GetPlayerPermissionGrants(granter, permission)
  local query = BSU.SQLSelectByValues(BSU.SQL_PP_GRANTS, { granter = BSU.ID64(steamid), permission = permission }) or {}

  local ids = {}
  for _, v in ipairs(query) do
    table.insert(ids, v)
  end

  return ids
end

-- returns if this player has been given a specific permission from the target player
function BSU.CheckPlayerHasPermission(ply, target, permission)
  return BSU.SQLSelectByValues(BSU.SQL_PP_GRANTS, { granter = BSU.ID64(target), receiver = BSU.ID64(ply), permission = permission }) ~= nil
end

-- same thing as BSU.CheckPlayerHasPermission but takes Player objects
function BSU.PlayerIsGranted(ply, target, perm)
  if not IsValid(target) then -- this also includes stuff owned by the world because IsValid(game.GetWorld()) returns false
    return false
  else
    return BSU.CheckPlayerHasPermission(ply:SteamID64(), target:SteamID64(), perm)
  end
end

function BSU.GrantPlayerPermission(ply, target, perm)
  BSU.RegisterPlayerPermission(ply:SteamID64(), target:SteamID64(), perm)
end

function BSU.DenyPlayerPermission(ply, target, perm)
  BSU.RemovePlayerPermission(ply:SteamID64(), target:SteamID64(), perm)
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
  ent:SetNW2String("BSU_OwnerID", owner ~= game.GetWorld() and owner:SteamID() or nil) -- this is used so we can identify the owner and give back ownership if they disconnect and then reconnect
end