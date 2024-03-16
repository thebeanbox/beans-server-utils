-- lib/server/limits.lua

function BSU.RegisterGroupLimit(groupid, name, amount)
	name = string.lower(name)

	-- incase this limit is already registered, remove the old one
	BSU.RemoveGroupLimit(groupid, name) -- sqlite's REPLACE INTO could've been implemented but removing and inserting is practically the same

	-- fix amount
	if not amount then
		local cvar = GetConVar("sbox_max" .. name)
		if cvar then amount = cvar:GetInt() end
	else
		amount = math.floor(amount)
	end

	BSU.SQLInsert(BSU.SQL_GROUP_LIMITS, {
		groupid = groupid,
		name = name,
		amount = amount
	})
end

function BSU.RemoveGroupLimit(groupid, name)
	name = string.lower(name)

	BSU.SQLDeleteByValues(BSU.SQL_GROUP_LIMITS, {
		groupid = groupid,
		name = name
	})
end

function BSU.GetAllGroupLimits()
	return BSU.SQLSelectAll(BSU.SQL_GROUP_LIMITS)
end

function BSU.GetGroupWildcardLimits(groupid)
	local query = BSU.SQLQuery("SELECT * FROM %s WHERE groupid = %s AND name LIKE '%%*%%'",
		BSU.SQLEscIdent(BSU.SQL_GROUP_LIMITS),
		BSU.SQLEscValue(groupid)
	)
	return query and BSU.SQLParse(query, BSU.SQL_GROUP_LIMITS) or {}
end

-- returns the amount the group can spawn for a specific limit (or nothing if the limit is not registered) (this excludes the cvar 'sbox_max<limit name>')
function BSU.GetGroupLimit(groupid, name, checkwildcards)
	name = string.lower(name)

	local limit = BSU.SQLSelectByValues(BSU.SQL_GROUP_LIMITS, { groupid = groupid, name = name })[1]

	if limit then
		return limit.amount
	else
		-- check wildcard limits
		if checkwildcards then
			local wildcards = BSU.GetGroupWildcardLimits(groupid, type)
			table.sort(wildcards, function(a, b) return #a.name > #b.name end)

			for _, v in ipairs(wildcards) do
				if string.find(name, string.Replace(v.name, "*", "(.-)")) ~= nil then
					return v.amount
				end
			end
		end

		-- check for limit in inherited group
		local inherit = BSU.GetGroupInherit(groupid)
		if inherit then
			return BSU.GetGroupLimit(inherit, name, checkwildcards)
		end
	end
end

-- returns the amount the player can spawn for a specific limit (or nothing if the limit is not registered) (this excludes the cvar 'sbox_max<limit name>')
function BSU.GetPlayerLimit(steamid, name, checkwildcards)
	steamid = BSU.ID64(steamid)

	-- check for limit in player's group
	local data = BSU.SQLSelectByValues(BSU.SQL_PLAYERS, { steamid = steamid })[1]
	if data then
		return BSU.GetGroupLimit(data.groupid, name, checkwildcards)
	end
end