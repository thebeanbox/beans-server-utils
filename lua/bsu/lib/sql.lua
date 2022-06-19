-- lib/sql.lua (SHARED)
-- handles some sql stuff and holds useful functions

-- if nil or NULL then "NULL" otherwise escape danger
function BSU.EscOrNULL(i, quotes)
  return not i or i == NULL and "NULL" or sql.SQLStr("" .. i, quotes or type(i) == "number")
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
  for _, v in ipairs(BSU.SQLQuery(string.format("PRAGMA table_info(%s)", BSU.EscOrNULL(tbl, true)))) do
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
        local type = columnData[k].type
        if type == "INTEGER" or type == "REAL" or type == "NUMERIC" or type == "BOOLEAN" then
          data[k] = tonumber(v)
        end
      end
    end
  end

  return data
end

-- inserts data into a sql table (keys are the column names)
function BSU.SQLInsert(tbl, data)
  local keys, values = {}, {}

  for k, v in pairs(data) do
    table.insert(keys, BSU.EscOrNULL(k, true))
    table.insert(values, BSU.EscOrNULL(v))
  end
  
  return BSU.SQLQuery("INSERT INTO '%s' (%s) VALUES(%s)",
    BSU.EscOrNULL(tbl, true),
    table.concat(keys, ","),
    table.concat(values, ",")
  )
end

-- returns every entry in a sql table
function BSU.SQLSelectAll(tbl)
  local query = BSU.SQLQuery("SELECT * FROM '%s'", BSU.EscOrNULL(tbl, true))

  if query then
    return BSU.SQLParse(query, tbl)
  end
  return {}
end

-- returns every entry in a sql table where a column equals the values
function BSU.SQLSelectByValues(tbl, values)
  if table.IsEmpty(values) then return end

  local conditions = {}
  for k, v in pairs(values) do
    table.insert(conditions, BSU.EscOrNULL(k, true) .. "=" .. BSU.EscOrNULL(v))
  end

  local query = BSU.SQLQuery("SELECT * FROM '%s' WHERE %s",
    BSU.EscOrNULL(tbl, true),
    table.concat(conditions, " AND ")
  )

  if query then
    return BSU.SQLParse(query, tbl)
  end
  return {}
end

-- deletes every entry in a sql table where a column equals the values
function BSU.SQLDeleteByValues(tbl, values)
  if table.IsEmpty(values) then return end

  local conditions = {}
  for k, v in pairs(values) do
    table.insert(conditions, BSU.EscOrNULL(k, true) .. "=" .. BSU.EscOrNULL(v))
  end

  return BSU.SQLQuery("DELETE FROM '%s' WHERE %s",
    BSU.EscOrNULL(tbl, true),
    table.concat(conditions, " AND ")
  )
end

-- updates a column in every entry in a sql table where a column equals the values
function BSU.SQLUpdateByValues(tbl, values, updatedValues)
  if table.IsEmpty(values) or table.IsEmpty(updatedValues) then return end

  local conditions = {}
  for k, v in pairs(values) do
    table.insert(conditions, BSU.EscOrNULL(k, true) .. "=" .. BSU.EscOrNULL(v))
  end

  local updates = {}
  for k, v in pairs(updatedValues) do
    table.insert(updates, BSU.EscOrNULL(k, true) .. "=" .. BSU.EscOrNULL(v))
  end

  return BSU.SQLQuery("UPDATE '%s' SET %s WHERE %s",
    BSU.EscOrNULL(tbl, true),
    table.concat(updates, ","),
    table.concat(conditions, " AND ")
  )
end

-- tries to create a new db table if it does not exist already
function BSU.SQLCreateTable(name, values)
  return BSU.SQLQuery("CREATE TABLE IF NOT EXISTS '%s' (%s)",
    BSU.EscOrNULL(name, true),
    BSU.EscOrNULL(values, true)
  )
end