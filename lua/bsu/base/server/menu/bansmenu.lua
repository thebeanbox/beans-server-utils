util.AddNetworkString("bsu_request_banlist")

net.Receive("bsu_request_banlist", function(len, ply)
	local page = net.ReadUInt(8) - 1
	local bansPerPage = net.ReadUInt(8)
	local allBans = BSU.GetAllBans()
	local bansRemaining = bansPerPage

	net.Start("bsu_request_banlist")
	for banIndex = 1, bansPerPage do
		local pageOffset = banIndex + page * 50
		
		username = "my awesome name"
		steamID = "steam:1234"
		banDuration = 1234
		bannedByUsername = "i banned you name"
		banDate = "monday tomorrow"

		net.WriteString(username) -- Name
		net.WriteString(steamID) -- SteamID
		net.WriteUInt(banDuration, 32) -- Duration (Seconds)
		net.WriteString(bannedByUsername) -- Banned by (Name)
		net.WriteString(banDate) -- Ban Date (Nice time)
	end
	net.Send(ply)
end)