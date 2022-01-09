-- lib/client/pp.lua

function BSU.RegisterPropPermission(steamid, permission)
  BSU.RemovePropPermission(steamid, permission) -- remove if already existing

  BSU.SQLInsert(BSU.SQL_PP,
    {
      steamid = BSU.ID64(steamid),
      permission = permission
    }
  )
end

function BSU.RemovePropPermission(steamid, permission)
  BSU.SQLDeleteByValues(BSU.SQL_PP, { steamid = BSU.ID64(steamid), permission = permission })
end

function BSU.GetPropPermissions(steamid)
  local query = BSU.SQLSelectByValues(BSU.SQL_PP, { steamid = BSU.ID64(steamid) }) or {}

  local perms = {}
  for _, v in ipairs(query) do
    table.insert(perms, v.permission)
  end
  return perms
end

-- returns a list of steam 64 bit ids the client has set a specific permission
function BSU.GetPropPermissionPlayers(permission)
  local query = BSU.SQLSelectByValues(BSU.SQL_PP, { permission = permission }) or {}

  local ids = {}
  for _, v in ipairs(query) do
    table.insert(ids, v)
  end

  return ids
end

function BSU.GrantPropPermission(ply, perm)
  if ply:IsBot() then return error("Cannot grant prop permission to a bot") end
  BSU.RegisterPropPermission(ply:SteamID64(), perm)
end

function BSU.RevokePropPermission(ply, perm)
  if ply:IsBot() then return error("Cannot grant prop permission to a bot") end
  BSU.RemovePropPermission(ply:SteamID64(), perm)
end

-- send prop protection data to the server
function BSU.SendPPClientData()
  local data = BSU.SQLSelectAll(BSU.SQL_PP) or {}

  net.Start("BSU_PPClientData_Init")
    net.WriteUInt(#data, 16)
    for _, v in ipairs(data) do
      net.WriteString(v.steamid)
      net.WriteUInt(v.permission, 3)
    end
  net.SendToServer()
end

-- update prop protection data on the server
function BSU.SendPPClientDataUpdate(method, steamid, permission)
  net.Start("BSU_PPClientData_Update")
    net.WriteBool(method) -- true to register data, false to remove data
    net.WriteString(steamid)
    net.WriteUInt(permission, 3)
  net.SendToServer()
end