-- lib/server/groups.lua
-- functions for managing the player groups

function BSU.RegisterGroup(id, name, color, usergroup, inherit)
  BSU.SQLInsert(BSU.SQL_GROUPS, {
    id = id,
    name = name,
    color = IsColor(color) and BSU.ColorToHex(color) or isstring(color) and string.gsub(color, "#", "") or "ffffff",
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
  return BSU.SQLSelectByValues(BSU.SQL_GROUPS, { id = id })[1]
end

-- get all groups with the same name (yes, groups can be given the same name)
function BSU.GetGroupsByName(name)
  return BSU.SQLSelectByValues(BSU.SQL_GROUPS, { name = name })
end

-- get all groups with the same usergroup
function BSU.GetGroupsByUsergroup(usergroup)
  return BSU.SQLSelectByValues(BSU.SQL_GROUPS, { usergroup = usergroup })
end

function BSU.SetGroupData(id, values)
  BSU.SQLUpdateByValues(BSU.SQL_GROUPS, { id = id }, values)
end

-- setup teams server-side
function BSU.SetupTeams()
  local groups = BSU.GetAllGroups()
  for k, v in ipairs(groups) do
    team.SetUp(v.id, v.name, BSU.HexToColor(v.color))
  end
end

-- setup teams on a client (nil to send data to all clients)
function BSU.ClientSetupTeams(ply)
  local groups = BSU.GetAllGroups()
  local teamData = {}
  for _, v in ipairs(groups) do
    teamData[v.id] = { name = v.name, color = BSU.HexToColor(v.color) }
  end

  BSU.ClientRPC(ply, "BSU.SetupTeams", teamData)
end

function BSU.PopulateTeams()
  BSU.SetupTeams()
  BSU.ClientSetupTeams()
end