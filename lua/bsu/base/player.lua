-- player.lua by Bonyoze

if SERVER then
	function BSU:GetPlayerData(ply)
		if not ply:IsValid() then ErrorNoHalt("Tried to get player data of null entity") return end

		local entry = sql.QueryRow("SELECT * FROM bsu_players WHERE steamId = '" .. ply:SteamID64() .. "'")

		if entry then
			return tonumber(entry.rankIndex)
		end
	end

	function BSU:SetPlayerData(ply, team)
		if not ply:IsValid() then ErrorNoHalt("Tried to set player data to null entity") return end

		if BSU:GetPlayerData(ply) then
			sql.Query("UPDATE bsu_players SET rankIndex = " .. team .. " WHERE steamId = '" .. ply:SteamID64() .. "'") -- update existing row
		else
			sql.Query("INSERT INTO bsu_players(steamId, rankIndex) VALUES('" .. ply:SteamID64() .. "', " .. team .. ")") -- insert new row
		end
	end

	function BSU:SetPlayerRank(ply, index)
		if not team.GetAllTeams()[index] then ErrorNoHalt("Tried to set ", ply, " to non-existing team with index ", index) return end
		
		BSU:SetPlayerData(ply, index)
		ply:SetTeam(index)
	end

	hook.Add("PlayerSpawn", "BSU_PlayerSetRank", function(ply)
		local rank = BSU:GetPlayerData(ply)

		if rank then
			ply:SetTeam(rank)
		else
			BSU:SetPlayerRank(ply, ply:IsBot() and BSU.BOT_RANK or BSU.DEFAULT_RANK)
		end
	end)
end