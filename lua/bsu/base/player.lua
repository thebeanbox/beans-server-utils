-- player.lua by Bonyoze

function BSU:GetPlayerPlayTime(ply)
	return ply.bsu and ply.bsu.playTime or 0
end

function BSU:GetPlayerKills(ply)
	return ply.bsu and ply.bsu.kills or 0
end

function BSU:GetPlayerStatus(ply)
	return ply:IsBot() and "offline" or (ply.bsu and ply.bsu.isAFK or false) and "away" or (ply.bsu and ply.bsu.isFocused == false or false) and "busy" or "online"
end

function BSU:GetPlayerCountry(ply)
	return not ply:IsBot() and ply.bsu and ply.bsu.country or ""
end

function BSU:GetPlayerIsLinux(ply)
	return not ply:IsBot() and ply.bsu and ply.bsu.isLinux or false
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
	util.AddNetworkString("BSU_ClientData")

	function BSU:GetPlayerDBData(ply)
		if not ply or not ply:IsValid() then ErrorNoHalt("Tried to get player data of null entity") return end

		local entry = sql.QueryRow("SELECT * FROM bsu_players WHERE steamId = '" .. ply:SteamID64() .. "'")

		if entry then
			return {
				rankIndex = tonumber(entry.rankIndex),
				playTime = tonumber(entry.playTime),
				rankColor = entry.rankColor != "NULL" and entry.rankColor or nil
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

	function BSU:SendClientData(ply, data, omit, targets)
		net.Start("BSU_ClientData")
			net.WriteEntity(ply)
			net.WriteData(util.Compress(util.TableToJSON(data)))
		if omit then net.SendOmit(ply) else net.Send(targets or player.GetAll()) end
	end

	function BSU:SetPlayerValue(ply, name, value)
		ply.bsu = ply.bsu or {}
		ply.bsu[name] = value
		BSU:SendClientData(ply, { [name] = ply.bsu[name] })
	end

	net.Receive("BSU_ClientData", function(len, ply)
		if not ply.bsu or (ply.bsu and ply.bsu.clientInitiated) then -- client init (send all existing client data to them)
			ply.bsu = ply.bsu or {}
			ply.bsu.clientInitiated = true
			for _, v in ipairs(player.GetAll()) do
				if v != ply and v.bsu then
					BSU:SendClientData(v, v.bsu, false, ply)
				end
			end
		end

		local data = util.JSONToTable(util.Decompress(net.ReadData(len)))
		BSU:ReceiveClientData(ply, data)
		BSU:SendClientData(ply, data, true)
	end)

	-- set player team
	hook.Add("PlayerSpawn", "BSU_SetPlayerTeam", function(ply)
		-- setup/receive player data in db
		local plyData = BSU:GetPlayerDBData(ply)
		if not plyData then
			BSU:SetPlayerDBData(ply, {
				rankIndex = ply:IsBot() and BSU.BOT_RANK or BSU.DEFAULT_RANK
			})

			plyData = BSU:GetPlayerDBData(ply) -- new data
		end

		-- set team
		ply:SetTeam(plyData.rankIndex)
	end)

	timer.Create("BSU_PlayerPlayTimeCounter", 1, 0, function()
		for _, ply in ipairs(player.GetAll()) do
			if not ply:IsBot() and (ply.bsu and ply.bsu.isAFK) then return end

			local plyData = BSU:GetPlayerDBData(ply)
			if plyData then
				local newVal = plyData.playTime + 1
				BSU:SetPlayerDBData(ply, { playTime = newVal })
				BSU:SetPlayerValue(ply, "playTime", newVal)
			end
		end
	end)

	-- track kills for players
	hook.Add("PlayerDeath", "BSU_PlayerKills", function(victim, inflict, attacker)
		if victim != attacker then BSU:SetPlayerValue(attacker, "kills", BSU:GetPlayerKills(attacker) + 1) end
	end)
else
	function BSU:SendClientData(data)
		net.Start("BSU_ClientData")
			net.WriteData(util.Compress(util.TableToJSON(data)))
		net.SendToServer()
	end

	hook.Add("InitPostEntity", "BSU_PlayerInit", function()
		-- receive other client data
		net.Receive("BSU_ClientData", function(len)
			BSU:ReceiveClientData(net.ReadEntity(), util.JSONToTable(util.Decompress(net.ReadData(len))))
		end)

		-- setup/send init data
		local initData = {
			isAFK = false,
			isLinux = system.IsLinux(),
			isFocused = system.HasFocus(),
			country = system.GetCountry()
		}
		LocalPlayer().bsu = initData
		BSU:SendClientData(initData)

		-- afk counter
		--[[if not LocalPlayer():IsBot() then
			local afkCounter = 0
			timer.Create("BSU_ClientAFKCounter", 1, 0, function()
				afkCounter = afkCounter + 1
			end)
		end]]

		-- check status of game window focus
		timer.Create("BSU_ClientWindowIsFocused", 1, 0, function()
			local focus = system.HasFocus()
			if LocalPlayer().bsu.isFocused != focus then
				LocalPlayer().bsu.isFocused = focus
				BSU:SendClientData({ isFocused = focus })
			end
		end)
	end)
end