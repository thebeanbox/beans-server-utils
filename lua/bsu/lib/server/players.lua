-- lib/server/players.lua
-- functions for handling player data

function BSU.RegisterPlayer(steamid, groupid)
  BSU.SQLInsert(BSU.SQL_PLAYERS, {
    steamid = BSU.ID64(steamid),
    groupid = groupid
  })
end

function BSU.GetAllPlayers()
  return BSU.SQLSelectAll(BSU.SQL_PLAYERS)
end

-- gets the data of all players in a group
function BSU.GetPlayerDataByGroup(groupid)
  return BSU.SQLSelectByValues(BSU.SQL_PLAYERS, { groupid = groupid })
end

-- sets a value of a player's data in the sql
function BSU.SetPlayerData(steamid, values)
  BSU.SQLUpdateByValues(BSU.SQL_PLAYERS, { steamid = BSU.ID64(steamid) }, values)
end

-- get player data using their steam id
function BSU.GetPlayerDataBySteamID(steamid)
  return BSU.SQLSelectByValues(BSU.SQL_PLAYERS, { steamid = BSU.ID64(steamid) })[1]
end

-- get player data using their player entity
function BSU.GetPlayerData(ply)
  return BSU.GetPlayerDataBySteamID(ply:SteamID64())
end

-- set the group of a player (also updates some other values)
function BSU.SetPlayerGroup(ply, groupid)
  BSU.SetPlayerData(ply:SteamID64(), { groupid = groupid })

  -- things that should update after a player's group changes
  ply:SetTeam(groupid) -- update team
  ply:SetUserGroup(BSU.GetGroupByID(groupid).usergroup) -- update usergroup
end

-- request the client to send some system info (os, country, timezone diff)
function BSU.RequestClientInfo(plys)
  BSU.ClientRPC(plys, "BSU.SendClientInfo")
end