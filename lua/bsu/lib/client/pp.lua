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
  local query = BSU.SQLSelectByValues(BSU.SQL_PP, { steamid = BSU.ID64(steamid) })

  local perms = {}
  for _, v in ipairs(query) do
    table.insert(perms, v.permission)
  end
  return perms
end

-- returns a list of steam 64 bit ids the client has set a specific permission
function BSU.GetPropPermissionPlayers(permission)
  local query = BSU.SQLSelectByValues(BSU.SQL_PP, { permission = permission })

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

-- send prop protection data to the server (takes a table of steamids or nil for all current players)
function BSU.SendPPData(steamids)
  if steamids and table.IsEmpty(steamids) then return end

  if not steamids then
    steamids = {}
    for _, v in ipairs(player.GetHumans()) do
      if v ~= LocalPlayer() and not v:IsBot() then
        table.insert(steamids, v:SteamID64())
      end
    end
  end

  local data = {}

  for _, v in ipairs(steamids) do
    local query = BSU.SQLSelectByValues(BSU.SQL_PP, { steamid = BSU.ID64(v) })[1]
    if query then
      table.insert(data, query)
    end
  end

  if table.IsEmpty(data) then return end

  net.Start("bsu_ppdata_init")
    net.WriteUInt(#data, 7) -- max of 127 entries (perfect because this is the max player limit excluding the local player)
    for _, v in ipairs(data) do
      net.WriteString(v.steamid)
      net.WriteUInt(v.permission, 3)
    end
  net.SendToServer()
end

-- update prop protection data on the server
function BSU.SendPPDataUpdate(method, steamid, permission)
  net.Start("bsu_ppdata_update")
    net.WriteBool(method) -- true to register data, false to remove data
    net.WriteString(steamid)
    net.WriteUInt(permission, 3)
  net.SendToServer()
end