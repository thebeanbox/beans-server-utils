-- players.lua by Bonyoze

MsgN("[BSU SERVER] Loaded players.lua")

hook.Add("PlayerInitialSpawn", "BSU_SetDBData", function(ply)
	-- create database entry if one doesn't exist
	if not sql.Query("SELECT * FROM bsu_players WHERE steamId = '" .. ply:SteamID64() .. "'") then
		sql.Query("INSERT INTO bsu_players(steamId, teamIndex) VALUES('" .. ply:SteamID64() .. "', 1)")
	end
end)