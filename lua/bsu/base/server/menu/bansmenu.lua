util.AddNetworkString("bsu_request_banlist2")

net.Receive("bsu_request_banlist2", function(len, ply)
	local canSeeBans = BSU.CheckPlayerPrivilege(ply:SteamID(), BSU.PRIV_MISC, "bsu_see_bans")
	if canSeeBans == false or canSeeBans == nil and not ply:IsAdmin() then return end

	local page = net.ReadUInt(8) - 1
	local bansPerPage = net.ReadUInt(8)
	local allBans = BSU.GetAllBans()
	local bans = {}

	-- Filter out kicks and inactive bans
	for _, ban in ipairs(allBans) do
		if ban.duration and (not ban.unbanTime and (ban.duration == 0 or (ban.time + ban.duration * 60) > BSU.UTCTime())) then table.insert(bans, ban) end
	end
	
	-- Sort remaining bans table
	if #bans > 0 then
		table.sort(bans, function(a, b) return a.time > b.time end)
	end

	local pageOffset = page * bansPerPage
	local bansRemaining = (#bans > bansPerPage) and (#bans - bansPerPage) or 0
	
	net.Start("bsu_request_banlist2")
	net.WriteUInt(#bans, 8)
	for i = 1, #bans do
		local ban = bans[pageOffset + i]
		if not ban then break end

		banUsername = BSU.IsValidIP(ban.identity) and ban.identity or (BSU.GetPlayerDataBySteamID(ban.identity, "name") and BSU.GetPlayerDataBySteamID(ban.identity, "name").name or "[NO NAME]")
		banSteamID = ban.identity
		banReason = ban.reason and ban.reason or "[NO REASON]"
		banDuration = ban.duration
		banDateNiceTime = os.date("%c", tonumber(ban.time))
		banDate = ban.time
		bannedByUsername = ban.admin and BSU.GetPlayerDataBySteamID(ban.admin, "name").name or "[CONSOLE]"
		bannedBySteamID = ban.admin and ban.admin or "[CONSOLE]"

		net.WriteString(banUsername)
		net.WriteString(banSteamID)
		net.WriteString(banReason)
		net.WriteUInt(banDuration, 32)
		net.WriteString(banDateNiceTime)
		net.WriteString(banDate)
		net.WriteString(bannedByUsername)
		net.WriteString(bannedBySteamID)
	end
	net.Send(ply)
end)