-- base/database.lua by Bonyoze
-- Manages the server database

sql.Query("CREATE TABLE IF NOT EXISTS bsu_players(steamId TEXT PRIMARY KEY, rankIndex INTEGER, playTime INTEGER DEFAULT 0, uniqueColor TEXT, permsOverride INTEGER DEFAULT 0)") -- player data
sql.Query("CREATE TABLE IF NOT EXISTS bsu_ranks(rankIndex INTEGER PRIMARY KEY, rankName TEXT NOT NULL, rankColor TEXT NOT NULL, userGroup TEXT DEFAULT 'user')") -- rank data
sql.Query("CREATE TABLE IF NOT EXISTS bsu_rankRestricts(rankIndex INTEGER NOT NULL, restriction TEXT NOT NULL)") -- rank restrictions

-- TEMPORARY RANK SETUP

function BSU:PopulateBSURanks()
  local bsuRanks = {
    [100] = {
      name = "Poopyfart",
      color = "3d2817"
    },
    [101] = {
      name = "Guest",
      color = "ffffff"
    },
    [102] = {
      name = "Frequent",
      color = "ebd3ff"
    },
    [103] = {
      name = "User",
      color = "ffb656"
    },
    [104] = {
      name = "Helper",
      color = "62af6b"
    },
    [105] = {
      name = "Mod",
      color = "4fe0ca"
    },
    [106] = {
      name = "Admin",
      color = "ff0059",
      userGroup = "admin"
    },
    [107] = {
       name = "Owner",
       color = "d664fd",
       userGroup = "superadmin"
    },
    [108] = {
      name = "Bot",
      color = "0074ff"
    }
  }

  for index, rank in pairs(bsuRanks) do
    sql.Query(
      string.format("INSERT INTO bsu_ranks(rankIndex, rankName, rankColor, userGroup) VALUES(%i, '%s', '%s', '%s')",
        index, rank.name, rank.color, rank.userGroup or "user"
      )
    )
  end
end

--BSU:PopulateBSURanks()
