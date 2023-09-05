util.AddNetworkString("bsu_request_bans")

net.Receive("bsu_request_bans", function(_, ply)
	local check = BSU.CheckPlayerPrivilege(ply:SteamID(), BSU.PRIV_MISC, "bsu_see_bans")
	if check == false or check == nil and not ply:IsAdmin() then return end

	local bansList = BSU.GetAllBans()
	table.sort(bansList, function(a, b) return a.time > b.time end)
	for i = #bansList, 1, -1 do
		if not bansList[i].duration then table.remove(bansList, i) end
	end

	local pageOffset = (net.ReadUInt(8) - 1) * 50
	local maxResults = math.min(#bansList, 50)

	net.Start("bsu_request_bans")
	net.WriteUInt(maxResults, 6)
	for i = 1, maxResults do
		local ban = bansList[i + pageOffset]
		if not ban then continue end

		net.WriteUInt(table.Count(ban), 4)
		for banKey, banValue in pairs(ban) do
			net.WriteString(banKey)
			net.WriteType(banValue)
		end
	end
	net.Send(ply)
end)