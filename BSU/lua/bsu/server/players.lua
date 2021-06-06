hook.Add("PlayerSpawn", "", function(ply)
	if not ply.bsuInit then
		ply.bsuInit = true
		
		if not sql.Query("SELECT * FROM bsu_players WHERE steamId = '" .. ply:SteamID64() .. "'") then
			sql.Query("INSERT INTO bsu_players(steamId, teamIndex) VALUES('" .. ply:SteamID64() .. "', 1)")
		end
	end
end)
