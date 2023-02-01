-- lib/server/teams.lua

function BSU.RegisterTeam(id, name, color)
	if not isnumber(id) then error("Team id must be a number") end

	BSU.SQLInsert(BSU.SQL_TEAMS, {
		id = id,
		name = name,
		color = IsColor(color) and BSU.ColorToHex(color) or isstring(color) and string.gsub(color, "#", "") or "ffffff"
	})
end

function BSU.RemoveTeam(id)
	BSU.SQLDeleteByValues(BSU.SQL_TEAMS, { id = id })
end

function BSU.GetAllTeams()
	return BSU.SQLSelectAll(BSU.SQL_TEAMS)
end

-- get team by its numeric id
function BSU.GetTeamByID(id)
	return BSU.SQLSelectByValues(BSU.SQL_TEAMS, { id = id })[1]
end

-- get team by its display name
function BSU.GetTeamByName(name)
	return BSU.SQLSelectByValues(BSU.SQL_TEAMS, { name = name })[1]
end

function BSU.SetTeamData(id, values)
	BSU.SQLUpdateByValues(BSU.SQL_TEAMS, { id = id }, values)
end

-- setup teams server-side
function BSU.SetupTeams()
	for _, v in ipairs(BSU.GetAllTeams()) do
		team.SetUp(v.id, v.name, BSU.HexToColor(v.color))
	end
end

-- setup teams on a client (nil to send data to all clients)
function BSU.ClientSetupTeams(ply)
	for _, v in ipairs(BSU.GetAllTeams()) do
		BSU.ClientRPC(ply, "team.SetUp", v.id, v.name, BSU.HexToColor(v.color))
	end
end