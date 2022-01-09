-- base/server/sql.lua

--[[
  Group SQL Tbl Info

  id        - (int)          numeric id of the group (automatically set and incremented) (also used for the team index of the group)
  name      - (text)         display name of the group
  color     - (text)         display color of the group
  usergroup - (text)         usergroup players under this group should be given (ex: "admin", "superadmin") (default: "user")
  inherit   - (int or NULL)  id of the group this group should inherit the properties of
]]

BSU.SQLCreateTable(BSU.SQL_GROUPS, string.format(
  [[
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    color TEXT NOT NULL,
    usergroup TEXT NOT NULL DEFAULT user,
    inherit INTEGER REFERENCES %s(id)
  ]],
    BSU.EscOrNULL(BSU.SQL_GROUPS, true)
))

--[[
  Player SQL Tbl Info

  steamid   - (text)        steam 64 bit id of the player
  groupid   - (int)         id of the group the player is currently in
  totaltime - (int)         (in seconds) how long the player has been on the server
  lastvisit - (int or NULL) (in seconds) utc unix timestamp when the player last connected to the server (NULL if first time joining)
  name      - (text)        steam name of the player
]]

BSU.SQLCreateTable(BSU.SQL_PLAYERS, string.format(
  [[
    steamid TEXT PRIMARY KEY,
    groupid INTEGER NOT NULL REFERENCES %s(id),
    totaltime INTEGER DEFAULT 0,
    lastvisit INTEGER,
    name TEXT
  ]],
    BSU.EscOrNULL(BSU.SQL_GROUPS, true)
))

--[[
  Ban SQL Tbl Info

  identity   - (text)         steam 64 bit id or ip address of the banned/kicked player
  reason     - (text or NULL) reason for the ban/kick (NULL if no reason given)
  duration   - (int or NULL)  (in minutes) how long the ban will last (0 for perma, NULL for kick)
  time       - (int)          utc unix timestamp when the ban/kick was done
  admin      - (text or NULL) steam 64 bit id of the admin who did the ban (NULL if done through rcon)
  unbanTime  - (int or NULL)  utc unix timestamp when the ban was manually resolved
  unbanAdmin - (text or NULL) steam 64 bit id of the admin who resolved the ban (NULL if done through rcon)

  (use the latest entry of a steamid or ip when checking ban status)
]]

BSU.SQLCreateTable(BSU.SQL_BANS, string.format(
  [[
    identity TEXT NOT NULL,
    reason TEXT,
    duration INTEGER,
    time INTEGER NOT NULL,
    admin TEXT REFERENCES %s(steamid),
    unbanTime INTEGER,
    unbanAdmin TEXT REFERENCES %s(steamid)
  ]],
    BSU.EscOrNULL(BSU.SQL_PLAYERS, true),
    BSU.EscOrNULL(BSU.SQL_PLAYERS, true)
))

--[[
  Group Privileges SQL Tbl Info

  groupid - (int)  id of the group
  type    - (text) privilege type
  value   - (text) privilege value
]]

BSU.SQLCreateTable(BSU.SQL_GROUP_PRIVS, string.format(
  [[
    groupid INTEGER NOT NULL REFERENCES %s(id),
    type INTEGER NOT NULL,
    value TEXT NOT NULL,
    granted BOOLEAN NOT NULL CHECK (granted in (0, 1))
  ]],
    BSU.EscOrNULL(BSU.SQL_GROUPS, true)
))

--[[
  Player Privileges SQL Tbl Info

  steamid - (text) steam 64 bit id of the player
  type    - (text) privilege type
  value   - (text) privilege value
]]

BSU.SQLCreateTable(BSU.SQL_PLAYER_PRIVS, string.format(
  [[
    steamid TEXT NOT NULL REFERENCES %s(steamid),
    type INTEGER NOT NULL,
    value TEXT NOT NULL,
    granted BOOLEAN NOT NULL CHECK (granted in (0, 1))
  ]],
    BSU.EscOrNULL(BSU.SQL_PLAYERS, true)
))

--[[
  Group Limits SQL Tbl Info

  groupid - (int)  id of the group
  name    - (text) name of the limit
  amount  - (int)  max spawn amount
]]

BSU.SQLCreateTable(BSU.SQL_GROUP_LIMITS, string.format(
  [[
    groupid INTEGER NOT NULL REFERENCES %s(id),
    name TEXT NOT NULL UNIQUE,
    amount INTEGER NOT NULL
  ]],
    BSU.EscOrNULL(BSU.SQL_GROUPS, true)
))

--[[
  Player Limits SQL Tbl Info

  steamid - (text) steam 64 bit id of the player
  name    - (text) name of the limit
  amount  - (int)  max spawn amount
]]

BSU.SQLCreateTable(BSU.SQL_PLAYER_LIMITS, string.format(
  [[
    steamid TEXT NOT NULL REFERENCES %s(steamid),
    name TEXT NOT NULL UNIQUE,
    amount INTEGER NOT NULL
  ]],
    BSU.EscOrNULL(BSU.SQL_PLAYERS, true)
))