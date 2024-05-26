-- lib/server/players.lua
-- functions for handling player data

function BSU.RegisterPlayer(steamid, groupid, team)
	BSU.SQLInsert(BSU.SQL_PLAYERS, {
		steamid = BSU.ID64(steamid),
		groupid = groupid,
		team = team -- overrides the team the player should use (uses the player's group team when not set)
	})
end

function BSU.GetAllPlayers()
	return BSU.SQLSelectAll(BSU.SQL_PLAYERS)
end

-- gets the data of all players in a group
function BSU.GetPlayerDataByGroup(groupid)
	return BSU.SQLSelectByValues(BSU.SQL_PLAYERS, { groupid = groupid })
end

-- get player data using their steam id
function BSU.GetPlayerDataBySteamID(steamid)
	return BSU.SQLSelectByValues(BSU.SQL_PLAYERS, { steamid = BSU.ID64(steamid) }, 1)[1]
end

-- get player data using their ip address
function BSU.GetPlayerDataByIPAddress(ip)
	return BSU.SQLSelectByValues(BSU.SQL_PLAYERS, { ip = BSU.Address(ip) })
end

-- get player data using their player entity
function BSU.GetPlayerData(ply)
	return BSU.GetPlayerDataBySteamID(ply:SteamID64())
end

-- sets a value of a player's data in the sql using their steam id
function BSU.SetPlayerDataBySteamID(steamid, values)
	BSU.SQLUpdateByValues(BSU.SQL_PLAYERS, { steamid = BSU.ID64(steamid) }, values)
end

-- sets a value of a player's data in the sql
function BSU.SetPlayerData(ply, values)
	BSU.SetPlayerDataBySteamID(ply:SteamID64(), values)
end

-- set the group of a player (also updates team and usergroup)
function BSU.SetPlayerGroup(ply, groupid)
	local groupData = BSU.GetGroupByID(groupid)
	if not groupData then error("Group does not exist") end

	BSU.SetPlayerData(ply, { groupid = groupid })
	if not BSU.GetPlayerData(ply).team then ply:SetTeam(groupData.team) end -- update team
	ply:SetUserGroup(groupData.usergroup) -- update usergroup
end

-- set the team of a player
function BSU.SetPlayerTeam(ply, team)
	local teamData = BSU.GetTeamByID(team)
	if not teamData then error("Team does not exist") end

	BSU.SetPlayerData(ply, { team = team })
	ply:SetTeam(team and team or BSU.GetGroupByID(BSU.GetPlayerData(ply).groupid).team) -- update team
end

-- reset the team of a player to use their group's team instead
function BSU.ResetPlayerTeam(ply)
	BSU.SetPlayerData(ply, { team = NULL })
	ply:SetTeam(BSU.GetGroupByID(BSU.GetPlayerData(ply).groupid).team) -- update team
end

-- request the client to send some system info (os, country, timezone diff)
function BSU.RequestClientInfo(plys)
	BSU.ClientRPC(plys, "BSU.SendClientInfo")
end