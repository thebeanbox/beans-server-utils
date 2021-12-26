-- lib/sql.lua (SHARED)
-- handles some sql stuff and holds useful functions

-- if nil then "NULL" otherwise escape danger
function BSU.EscOrNULL(i, quotes)
  return not i and "NULL" or sql.SQLStr("" .. i, quotes or type(i) == "number")
end

-- tries to create a new db table if it does not exist already
function BSU.SQLCreateTable(name, values)
  local query = sql.Query(
    string.format("CREATE TABLE IF NOT EXISTS '%s' (%s)",
      BSU.EscOrNULL(name, true),
      BSU.EscOrNULL(values, true)
    )
  )
  if query == false then error(sql.LastError()) end
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

-- fixes up the output of sql queries
function BSU.SQLParse(data, tbl)
  if not tbl then return error("Tried to parse but SQL table wasn't specified!") end
  
  if table.IsSequential(data) then -- multiple entries
    for k, v in ipairs(data) do
      data[k] = BSU.SQLParse(v, tbl)
    end
  else
    for k, v in pairs(data) do
      if v == "NULL" then
        data[k] = nil
      else
        local typeof = BSU.SQLQueryValue("SELECT typeof(%s) FROM '%s'",
          BSU.EscOrNULL(k, true),
          BSU.EscOrNULL(tbl, true)
        )
        
        if typeof == "integer" then
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
  
  BSU.SQLQuery("INSERT INTO '%s' (%s) VALUES(%s)",
    BSU.EscOrNULL(tbl, true),
    table.concat(keys, ","),
    table.concat(values, ",")
  )
end

-- returns everything in a sql table (or nothing if it's empty)
function BSU.SQLSelectAll(tbl)
  local query = BSU.SQLQuery("SELECT * FROM '%s'", BSU.EscOrNULL(tbl, true))

  if query then
    return BSU.SQLParse(query, tbl)
  end
end

-- returns every entry in a sql table where a column equals the values (or nothing if there are none)
function BSU.SQLSelectByValues(tbl, values)
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
end

-- deletes every entry in a sql table where a column equals the values
function BSU.SQLDeleteByValues(tbl, values)
  local conditions = {}
  for k, v in pairs(values) do
    table.insert(conditions, BSU.EscOrNULL(k, true) .. "=" .. BSU.EscOrNULL(v))
  end

  BSU.SQLQuery("DELETE FROM '%s' WHERE %s",
    BSU.EscOrNULL(tbl, true),
    table.concat(conditions, " AND ")
  )
end

-- updates a column in every entry in a sql table where a column equals the values
function BSU.SQLUpdateByValues(tbl, values, updatedValues)
  local conditions = {}
  for k, v in pairs(values) do
    table.insert(conditions, BSU.EscOrNULL(k, true) .. "=" .. BSU.EscOrNULL(v))
  end

  local updates = {}
  for k, v in pairs(updatedValues) do
    table.insert(updates, BSU.EscOrNULL(k, true) .. "=" .. BSU.EscOrNULL(v))
  end

  BSU.SQLQuery("UPDATE '%s' SET %s WHERE %s",
    BSU.EscOrNULL(tbl, true),
    table.concat(updates, ","),
    table.concat(conditions, " AND ")
  )
end