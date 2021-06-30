-- create tables if they don't exist

sql.Query("CREATE TABLE bsu_players(steamId TEXT PRIMARY KEY, teamIndex NUMBER)") -- player data

sql.Query("CREATE TABLE bsu_teams(teamIndex NUMBER PRIMARY KEY, teamName TEXT, teamColor TEXT, afkTimeout NUMBER)") -- team data

sql.Query("CREATE TABLE bsu_teamRestricts(teamIndex NUMBER, restriction TEXT)") -- team restrictions