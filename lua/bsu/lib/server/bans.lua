-- lib/server/bans.lua
-- functions for managing bans

function BSU.RegisterBan(identity, reason, duration, admin) -- this is also used for logging kicks (when duration = null)
	BSU.SQLInsert(BSU.SQL_BANS, {
		identity = identity,
		reason = reason,
		duration = duration,
		time = BSU.UTCTime(),
		admin = admin and BSU.ID64(admin)
	})
end

-- returns a sequential table of every ban and kick performed on the server
function BSU.GetAllBans()
	return BSU.SQLSelectAll(BSU.SQL_BANS)
end

-- returns a sequential table of every kick ever performed on the server
function BSU.GetKickHistory(identity)
	identity = BSU.ValidateIdentity(identity)

	local allBans = BSU.GetAllBans()
	local kicks = {}

	if identity then
		for _, ban in ipairs(allBans) do
			if identity == ban.identity and not ban.duration then table.insert(kicks, ban) end
		end
	else
		for _, ban in ipairs(allBans) do
			if not ban.duration then table.insert(kicks, ban) end
		end
	end

	return kicks
end

-- returns a sequential table of every ban ever performed on the server
function BSU.GetBanHistory(identity)
	identity = BSU.ValidateIdentity(identity)

	local allBans = BSU.GetAllBans()
	local bans = {}

	if identity then
		for _, ban in ipairs(allBans) do
			if identity == ban.identity and ban.duration then table.insert(bans, ban) end
		end
	else
		for _, ban in ipairs(allBans) do
			if ban.duration then table.insert(bans, ban) end
		end
	end

	return bans
end

-- returns a sequential table of all the currently active bans
function BSU.GetActiveBans()
	local allBans = BSU.GetBanHistory()
	local activeBans = {}

	for _, ban in ipairs(allBans) do
		if not ban.unbanTime and (ban.duration == 0 or (ban.time + ban.duration * 60) > BSU.UTCTime()) then table.insert(activeBans, ban) end
	end

	return activeBans
end

function BSU.GetBansByValues(values)
	return BSU.SQLSelectByValues(BSU.SQL_BANS, values)
end

-- returns data of the latest ban if they are still banned, otherwise nothing if they aren't currently banned (can take a steam id or ip address)
function BSU.GetBanStatus(identity)
	-- correct the argument (steam id to 64 bit) (removing port from ip address)
	identity = BSU.ValidateIdentity(identity)
	if not identity then return end

	local bans = {}
	for _, v in ipairs(BSU.GetBansByValues({ identity = identity })) do -- exclude kicks since they're also logged
		if v.duration then table.insert(bans, v) end
	end

	if #bans > 0 then
		table.sort(bans, function(a, b) return a.time > b.time end) -- sort from latest to oldest

		local latestBan = bans[1]

		if not latestBan.unbanTime and (latestBan.duration == 0 or (latestBan.time + latestBan.duration * 60) > BSU.UTCTime()) then -- this guy is perma'd or still banned
			return latestBan
		end
	end
end

-- ban a player by steam id (this adds a new ban entry so it will be the new ban status for this player)
function BSU.BanSteamID(steamid, reason, duration, adminid)
	steamid = BSU.ID64(steamid)

	BSU.RegisterBan(steamid, reason, duration or 0, adminid and BSU.ID64(adminid) or nil)

	game.KickID(util.SteamIDFrom64(steamid), "(Banned) " .. (reason or "No reason given"))
end

-- ban a player by ip (this adds a new ban entry so it will be the new ban status for this player)
function BSU.BanIP(ip, reason, duration, adminid)
	ip = BSU.Address(ip)

	BSU.RegisterBan(ip, reason, duration or 0, adminid and BSU.ID64(adminid) or nil)

	for _, v in ipairs(player.GetHumans()) do -- try to kick all players with this ip
		if BSU.Address(v:IPAddress()) == ip then
			game.KickID(v:UserID(), "(Banned) " .. (reason or "No reason given"))
		end
	end
end

-- unban a player by steam id
function BSU.RevokeSteamIDBan(steamid, admin)
	local lastBan = BSU.GetBanStatus(steamid)
	if not lastBan then return error("Steam ID is not currently banned") end

	BSU.SQLUpdateByValues(BSU.SQL_BANS, lastBan, { unbanTime = BSU.UTCTime(), unbanAdmin = IsValid(admin) and admin:SteamID64() or nil })
end

-- unban a player by ip
function BSU.RevokeIPBan(ip, admin)
	local lastBan = BSU.GetBanStatus(ip)
	if not lastBan then return error("IP is not currently banned") end

	BSU.SQLUpdateByValues(BSU.SQL_BANS, lastBan, { unbanTime = BSU.UTCTime(), unbanAdmin = IsValid(admin) and admin:SteamID64() or nil })
end

function BSU.BanPlayer(ply, reason, duration, admin)
	if ply:IsBot() then return error("Unable to ban a bot, try kicking") end
	BSU.BanSteamID(ply:SteamID64(), reason, duration, IsValid(admin) and admin:SteamID64() or nil)
	hook.Run("BSU_PlayerBanned", ply, reason, duration, admin)
end

function BSU.IPBanPlayer(ply, reason, duration, admin)
	if ply:IsBot() then return error("Unable to ip ban a bot, try kicking") end
	BSU.BanIP(ply:IPAddress(), reason, duration, IsValid(admin) and admin:SteamID64() or nil)
end

function BSU.KickPlayer(ply, reason, admin)
	BSU.RegisterBan(ply:SteamID64(), reason, nil, IsValid(admin) and admin:SteamID64() or nil) -- log it
	game.KickID(ply:UserID(), "(Kicked) " .. (reason or "No reason given"))
	hook.Run("BSU_PlayerKicked", ply, reason, admin)
end

-- formats a ban message that shows ban reason, duration, time left and the date of the ban
-- duration should be the ban length in mins and time should be the ban time in UTC secs
-- timezoneOffset is used for adjusting the time in different timezones (if it's not set UTC time is used)
function BSU.FormatBanMsg(reason, duration, time, timezoneOffset)
	return string.gsub(BSU.BAN_MSG, "%%([%w_]+)%%",
		{
			reason = reason or "(None given)",
			duration = duration == 0 and "(Permaban)" or BSU.StringTime(duration),
			remaining = duration == 0 and "(Permaban)" or BSU.StringTime(math.ceil(time / 60 + duration - BSU.UTCTime() / 60)),
			time = os.date("!%a, %b %d, %Y - %I:%M:%S %p", time + (timezoneOffset and timezoneOffset * 3600 or 0)) .. " (" .. (BSU.UTCTime() - time < 60 and "A few seconds ago" or BSU.StringTime(math.ceil(BSU.UTCTime() / 60 - time / 60 - 1)) .. " ago") .. ")"
		}
	)
end

