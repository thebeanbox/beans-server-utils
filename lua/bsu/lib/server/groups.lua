-- lib/server/groups.lua
-- functions for managing the player groups

function BSU.RegisterGroup(id, team, usergroup, inherit)
	id = string.match(id, "^[%w_]+$")
	if not id then error("Group id can only have letters, digits, and underscores") end

	BSU.SQLReplace(BSU.SQL_GROUPS, {
		id = string.lower(id),
		team = team,
		usergroup = usergroup,
		inherit = inherit
	})
end

function BSU.RemoveGroup(id)
	BSU.SQLDeleteByValues(BSU.SQL_GROUPS, { id = id })
end

function BSU.GetAllGroups()
	return BSU.SQLSelectAll(BSU.SQL_GROUPS)
end

-- get group by its numeric id
function BSU.GetGroupByID(id)
	return BSU.SQLSelectByValues(BSU.SQL_GROUPS, { id = id }, 1)[1]
end

-- get groups by with the same team
function BSU.GetGroupsByTeam(team)
	return BSU.SQLSelectByValues(BSU.SQL_GROUPS, { team = team })
end

-- get all groups with the same usergroup
function BSU.GetGroupsByUsergroup(usergroup)
	return BSU.SQLSelectByValues(BSU.SQL_GROUPS, { usergroup = usergroup })
end

-- get all groups which inherit from a certain group
function BSU.GetGroupsByInherit(inherit)
	return BSU.SQLSelectByValues(BSU.SQL_GROUPS, { inherit = inherit })
end

function BSU.SetGroupData(id, values)
	BSU.SQLUpdateByValues(BSU.SQL_GROUPS, { id = id }, values)
end