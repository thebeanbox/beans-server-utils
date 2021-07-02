-- database.lua by Bonyoze
-- Manages the server database

MsgN("[BSU SERVER] Loaded database.lua")

sql.Query("CREATE TABLE bsu_players(steamId TEXT PRIMARY KEY, teamIndex NUMBER)") -- player data
sql.Query("CREATE TABLE bsu_teams(teamIndex NUMBER PRIMARY KEY, teamName TEXT, teamColor TEXT, afkTimeout NUMBER)") -- team data
sql.Query("CREATE TABLE bsu_teamRestricts(teamIndex NUMBER, restriction TEXT)") -- team restrictions

MsgN("[BSU SERVER - database.lua] Setup the database")