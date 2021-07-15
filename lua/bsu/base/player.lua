-- player.lua by Bonyoze

function BSU:GetPlayerPlayTime(ply)
	return ply:GetNWInt("playTime")
end

function BSU:GetPlayerKills(ply)
	return ply:GetNWInt("kills")
end

function BSU:GetPlayerStatus(ply)
	return ply:IsBot() and "offline" or ply:GetNWBool("isAFK") and "away" or ply:GetNWBool("isFocused") == false and "busy" or "online"
end

function BSU:GetPlayerCountry(ply)
	return not ply:IsBot() and ply:GetNWString("country")
end

function BSU:GetPlayerOS(ply)
	return not ply:IsBot() and ply:GetNWString("os")
end

function BSU:GetPlayerMode(ply)
	return "build" -- temporary
end

function BSU:ReceiveClientData(ply, data)
	ply.bsu = ply.bsu or {}
	for k, v in pairs(data) do
		ply.bsu[k] = v
	end
end

if SERVER then
	util.AddNetworkString("BSU_ClientInit")
	util.AddNetworkString("BSU_ClientAFKStatus")
	util.AddNetworkString("BSU_ClientFocusedStatus")

	function BSU:GetPlayerDBData(ply)
		if not ply or not ply:IsValid() then ErrorNoHalt("Tried to get player data of null entity") return end

		local entry = sql.QueryRow("SELECT * FROM bsu_players WHERE steamId = '" .. ply:SteamID64() .. "'")

		if entry then
			return {
				rankIndex = tonumber(entry.rankIndex),
				playTime = tonumber(entry.playTime),
				uniqueColor = entry.uniqueColor != "NULL" and entry.uniqueColor or nil
			}
		end
	end

	function BSU:SetPlayerDBData(ply, data)
		if not ply:IsValid() then ErrorNoHalt("Tried to set player data to null entity") return end

		if not BSU:GetPlayerDBData(ply) then -- insert a new row
			sql.Query("INSERT INTO bsu_players(steamId) VALUES('" .. ply:SteamID64() .. "')")
		end
		-- update with the data
		for k, v in pairs(data) do
			sql.Query("UPDATE bsu_players SET " .. k .. " = " .. sql.SQLStr(tostring(v)) .. " WHERE steamId = '" .. ply:SteamID64() .. "'")
		end
	end

	function BSU:SetPlayerRank(ply, index)
		BSU:SetPlayerDBData(ply, {
			rankIndex = index
		})
		ply:SetTeam(index)
		
		local color = BSU:GetRank(index).color
		ply:SetNWVector("color", Vector(color.r, color.g, color.b))
	end

	function BSU:GetPlayerColor(ply)
		local plyData = BSU:GetPlayerDBData(ply)

		local uniqueColor = ply:GetNWVector("uniqueColor")

		if uniqueColor != Vector() then
			uniqueColor = Color(uniqueColor[1], uniqueColor[2], uniqueColor[3])
		elseif plyData and plyData.uniqueColor then
			uniqueColor = BSU:HexToColor(plyData.uniqueColor)
		else
			uniqueColor = nil
		end

		local color = ply:GetNWVector("color")

		if color != Vector() then
			color = Color(color[1], color[2], color[3])
		elseif plyData then
			color = BSU:GetRank(plyData.rankIndex).color
		else
			color = nil
		end

		return uniqueColor or color or team.GetColor(ply:IsBot() and BSU.BOT_RANK or BSU.DEFAULT_RANK)
	end

	net.Receive("BSU_ClientInit", function(_, ply)
		local country, os = net.ReadString(), net.ReadString()

		ply:SetNWString("country", country)
		ply:SetNWString("os", os)
	end)

	net.Receive("BSU_ClientFocusedStatus", function(_, ply)
		local isFocused = net.ReadBool()

		ply:SetNWBool("isFocused", isFocused)
	end)
	
	hook.Add("PlayerSpawn", "BSU_SetPlayerTeam", function(ply)
		if ply:Team() == 1001 then -- if unassigned then setup rank/team
			local data = BSU:GetPlayerDBData(ply)

			if not data then
				BSU:SetPlayerRank(ply, ply:IsBot() and BSU.BOT_RANK or BSU.DEFAULT_RANK)
				data = BSU:GetPlayerDBData(ply) -- new data
			else
				ply:SetTeam(data.rankIndex)

				local color = BSU:GetRank(data.rankIndex).color
				ply:SetNWVector("color", Vector(color.r, color.g, color.b))
			end

			if data.uniqueColor then
				local color = BSU:HexToColor(data.uniqueColor)
				ply:SetNWVector("uniqueColor", Vector(color.r, color.g, color.b))
			end
		end
	end)

	timer.Create("BSU_PlayerPlayTimeCounter", 1, 0, function()
		for _, ply in ipairs(player.GetAll()) do
			if not ply:IsBot() and (ply.bsu and ply.bsu.isAFK) then return end

			local plyData = BSU:GetPlayerDBData(ply)
			if plyData then
				local newVal = plyData.playTime + 1
				BSU:SetPlayerDBData(ply, { playTime = newVal })
				ply:SetNWInt("playTime", newVal)
			end
		end
	end)

	-- track kills for players
	hook.Add("PlayerDeath", "BSU_PlayerKills", function(victim, inflict, attacker)
		if victim != attacker then attacker:SetNWInt("kills", attacker:GetNWInt("kills") + 1) end
	end)
else
	function BSU:GetPlayerColor(ply)
		local uniqueColor = ply:GetNWVector("uniqueColor")

		if uniqueColor != Vector() then
			uniqueColor = Color(uniqueColor[1], uniqueColor[2], uniqueColor[3])
		else
			uniqueColor = nil
		end

		local color = ply:GetNWVector("color")

		if color != Vector() then
			color = Color(color[1], color[2], color[3])
		else
			color = nil
		end

		return uniqueColor or color or team.GetColor(ply:IsBot() and BSU.BOT_RANK or BSU.DEFAULT_RANK)
	end

	hook.Add("InitPostEntity", "BSU_PlayerInit", function()

		net.Start("BSU_ClientInit")
			net.WriteString(system.GetCountry())
			net.WriteString(system.IsWindows() and "windows" or system.IsLinux() and "linux" or system.IsOSX() and "mac")
		net.SendToServer()

		-- afk counter
		--[[if not LocalPlayer():IsBot() then
			local afkCounter = 0
			timer.Create("BSU_ClientAFKCounter", 1, 0, function()
				afkCounter = afkCounter + 1
			end)
		end]]

		-- check status of game window focus
		local lastFocused = system.HasFocus()
		timer.Create("BSU_ClientWindowIsFocused", 1, 0, function()
			local currFocused = system.HasFocus()
			if lastFocused != currFocused then
				lastFocused = currFocused
				net.Start("BSU_ClientAFKStatus")
					net.WriteBool(currFocused)
				net.SendToServer()
			end
		end)
	end)
end
