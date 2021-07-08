-- database.lua by Bonyoze
-- Manages the server database

sql.Query("CREATE TABLE IF NOT EXISTS bsu_players(steamId TEXT PRIMARY KEY, rankIndex INTEGER)") -- player data
sql.Query("CREATE TABLE IF NOT EXISTS bsu_ranks(rankIndex INTEGER PRIMARY KEY, rankName TEXT, rankColor TEXT, afkTimeout INTEGER)") -- rank data
sql.Query("CREATE TABLE IF NOT EXISTS bsu_rankRestricts(rankIndex INTEGER, restriction TEXT)") -- rank restrictions

// TEMPORARY RANK SETUP

/*local bsuRanks = {
  [100] = {
    name = "Poopyfart",
    color = "3d2817",
    afk = 15 * 60
  },
  [101] = {
    name = "Guest",
    color = "ffffff",
    afk = 15 * 60
  },
  [102] = {
    name = "Frequent",
    color = "ebd3ff",
    afk = 30 * 60
  },
  [103] = {
    name = "User",
    color = "ffb656",
    afk = 30 * 60
  },
  [104] = {
    name = "Helper",
    color = "62af6b",
    afk = 45 * 60
  },
  [105] = {
    name = "Mod",
    color = "4fe0ca",
    afk = 45 * 60
  },
  [106] = {
    name = "Admin",
    color = "ff0059",
    afk = 60 * 60
  },
  [107] = {
    name = "Bot",
    color = "0074ff",
    afk = 60 * 60
  }
}

for index, rank in pairs(bsuRanks) do
  sql.Query(
    string.format("INSERT INTO bsu_ranks(rankIndex, rankName, rankColor, afkTimeout) VALUES(%i, '%s', '%s', %i)",
      index, rank.name, rank.color, rank.afk
    )
  )
end

PrintTable(sql.Query("SELECT * FROM bsu_ranks"))*/