util.AddNetworkString("bsu_request_banlist")

net.Receive("bsu_request_banlist", function(_, ply)
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

	net.Start("bsu_request_banlist")
	net.WriteUInt(#bans, 8)
	for i = 1, #bans do
		local ban = bans[pageOffset + i]
		if not ban then break end -- What?

		local banUsername = BSU.IsValidIP(ban.identity) and ban.identity or (BSU.GetPlayerDataBySteamID(ban.identity) and BSU.GetPlayerDataBySteamID(ban.identity).name or "N/A")
		local banSteamID = ban.identity
		local banReason = ban.reason and ban.reason or "N/A"
		local banDuration = ban.duration
		local banDate = ban.time
		local bannedByUsername = ban.admin and BSU.GetPlayerDataBySteamID(ban.admin).name or "[CONSOLE]"
		local bannedBySteamID = ban.admin and ban.admin or "[CONSOLE]"

		net.WriteString(banUsername)
		net.WriteString(banSteamID)
		net.WriteString(banReason)
		net.WriteUInt(banDuration, 32)
		net.WriteUInt(banDate, 32)
		net.WriteString(bannedByUsername)
		net.WriteString(bannedBySteamID)
	end
	net.Send(ply)
end)

