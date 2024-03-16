-- lib/sql.lua (SHARED)
-- handles some sql stuff and holds useful functions

local function sqlEscape(str, quotes)
	str = tostring(str)

	str = string.gsub(str, quotes, quotes .. quotes)

	local null_chr = string.find(str, "\0")
	if null_chr then
		str = string.sub(str, 1, null_chr - 1)
	end

	return quotes .. str .. quotes
end

-- escapes an identifier to be put in a query
function BSU.SQLEscIdent(i)
	return sqlEscape(i, "\"")
end

-- escapes a value to be put in a query
function BSU.SQLEscValue(v)
	local t = type(v)
	if t == "number" then
		if v ~= v then -- sqlite converts NaN to NULL
			return "NULL"
		elseif v == math.huge then
			return "1e999"
		elseif v == -math.huge then
			return "-1e999"
		end
		return tostring(v)
	elseif t == "boolean" then
		return v and "1" or "0"
	elseif t == "string" then
		return sqlEscape(v, "'")
	end
	return "NULL"
end

-- checks if query errored or not
local function safeQuery(query)
	if query == false then
		return error(sql.LastError())
	else
		return query
	end
end

function BSU.SQLQuery(syntax, ...)
	return safeQuery(sql.Query(string.format(syntax, ...)))
end

function BSU.SQLQueryValue(syntax, ...)
	return safeQuery(sql.QueryValue(string.format(syntax, ...)))
end

function BSU.SQLGetColumnData(tbl)
	local data = {}
	for _, v in ipairs(BSU.SQLQuery("PRAGMA table_info(%s)", BSU.SQLEscIdent(tbl))) do
		local name = v.name
		v.name = nil
		data[name] = v
	end
	return data
end

-- fixes up the output of sql queries
function BSU.SQLParse(data, tbl)
	if not tbl then return error("Tried to parse but SQL table wasn't specified!") end

	if table.IsSequential(data) then -- multiple entries
		for k, v in ipairs(data) do
			data[k] = BSU.SQLParse(v, tbl)
		end
	else
		local columnData = BSU.SQLGetColumnData(tbl)

		for k, v in pairs(data) do
			if v == "NULL" then
				data[k] = nil
			else
				local t = columnData[k].type
				if t == "INTEGER" or t == "REAL" or t == "NUMERIC" then
					-- note: GMod sqlite's handling of Infinity and -Infinity
					--[[
						> PrintTable(sql.QueryRow("SELECT 1e999, -1e999"))...
						-1e999  =       -Inf
						1e999   =       Inf
					]]
					if v == "Inf" then
						data[k] = math.huge
					elseif v == "-Inf" then
						data[k] = -math.huge
					else
						data[k] = tonumber(v)
					end
				elseif t == "BOOLEAN" then
					data[k] = tonumber(v) ~= 0
				end
			end
		end
	end

	return data
end

-- inserts data into a sql table (keys are the column names)
function BSU.SQLInsert(tbl, data)
	local columns, values = {}, {}

	for k, v in pairs(data) do
		table.insert(columns, BSU.SQLEscIdent(k))
		table.insert(values, BSU.SQLEscValue(v))
	end

	return BSU.SQLQuery("INSERT INTO %s (%s) VALUES(%s)",
		BSU.SQLEscIdent(tbl),
		table.concat(columns, ","),
		table.concat(values, ",")
	)
end

-- returns every entry in a sql table
function BSU.SQLSelectAll(tbl)
	local query = BSU.SQLQuery("SELECT * FROM %s", BSU.SQLEscIdent(tbl))

	if query then
		return BSU.SQLParse(query, tbl)
	end
	return {}
end

-- returns every entry in a sql table where a column equals the values
function BSU.SQLSelectByValues(tbl, values)
	if next(values) == nil then return {} end

	local conditions = {}
	for k, v in pairs(values) do
		table.insert(conditions, string.format("%s = %s", BSU.SQLEscIdent(k), BSU.SQLEscValue(v)))
	end

	local query = BSU.SQLQuery("SELECT * FROM %s WHERE %s",
		BSU.SQLEscIdent(tbl),
		table.concat(conditions, " AND ")
	)

	if query then
		return BSU.SQLParse(query, tbl)
	end
	return {}
end

-- deletes every entry in a sql table where a column equals the values
function BSU.SQLDeleteByValues(tbl, values)
	if next(values) == nil then return end

	local conditions = {}
	for k, v in pairs(values) do
		table.insert(conditions, string.format("%s = %s", BSU.SQLEscIdent(k), BSU.SQLEscValue(v)))
	end

	return BSU.SQLQuery("DELETE FROM %s WHERE %s",
		BSU.SQLEscIdent(tbl),
		table.concat(conditions, " AND ")
	)
end

-- updates a column in every entry in a sql table where a column equals the values
function BSU.SQLUpdateByValues(tbl, values, updatedValues)
	if next(values) == nil or next(updatedValues) == nil then return end

	local conditions = {}
	for k, v in pairs(values) do
		table.insert(conditions, string.format("%s = %s", BSU.SQLEscIdent(k), BSU.SQLEscValue(v)))
	end

	local updates = {}
	for k, v in pairs(updatedValues) do
		table.insert(updates, string.format("%s = %s", BSU.SQLEscIdent(k), BSU.SQLEscValue(v)))
	end

	return BSU.SQLQuery("UPDATE %s SET %s WHERE %s",
		BSU.SQLEscIdent(tbl),
		table.concat(updates, ","),
		table.concat(conditions, " AND ")
	)
end

-- helper function to create a new db table if it does not exist already
function BSU.SQLCreateTable(name, values)
	return BSU.SQLQuery("CREATE TABLE IF NOT EXISTS %s (%s)",
		BSU.SQLEscIdent(name),
		values -- this isn't sanitized correctly but you shouldn't be letting clients create tables anyway
	)
end