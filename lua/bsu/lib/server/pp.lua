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

function BSU.CheckPlayerHasPermission(granter, receiver, permission)
  return BSU.SQLSelectByValues(BSU.SQL_PP_GRANTS, { granter = BSU.ID64(granter), receiver = BSU.ID64(receiver), permission = permission }) ~= nil
end

function BSU.PlayerIsGranted(ply, target, perm)
  return BSU.CheckPlayerHasPermission(ply:SteamID64(), target:SteamID64(), perm)
end

function BSU.GrantPlayerPermission(ply, target, perm)
  BSU.RegisterPlayerPermission(ply:SteamID64(), target:SteamID64(), perm)
end

function BSU.DenyPlayerPermission(ply, target, perm)
  BSU.RemovePlayerPermission(ply:SteamID64(), target:SteamID64(), perm)
end

function BSU.SetEntityOwnerless(ent)
  ent:SetNW2Entity("BSU_Owner", nil)
  ent:SetNW2Entity("BSU_OwnerName", nil)
  ent:SetNW2Entity("BSU_OwnerID", nil)
end

function BSU.SetEntityOwner(ent, owner)
  if ent:IsPlayer() then return error("Entity cannot be a player") end
  if not owner or (not owner:IsPlayer() and not owner == game.GetWorld()) then return error("Entity owner must be the world or a player") end

  ent:SetNW2Entity("BSU_Owner", owner)

  -- this is so we can still get the name and id of the player after they leave the server
  ent:SetNW2String("BSU_OwnerName", owner ~= game.GetWorld() and owner:Nick() or "World") -- this is used for the hud
  if owner ~= game.GetWorld() then
    ent:SetNW2String("BSU_OwnerID", owner:SteamID()) -- this is used so we can identify the owner and give back ownership if they disconnect and then reconnect
  end
end