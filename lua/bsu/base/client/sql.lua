-- base/client/sql.lua

--[[
  Prop Protection SQL Tbl Info

  steamid    - (text) steam 64 bit id of the player being targetted
  permission - (int)  the permission being set
]]

BSU.SQLCreateTable(BSU.SQL_PP, string.format(
  [[
    steamid TEXT NOT NULL,
    permission INTEGER NOT NULL
  ]]
))