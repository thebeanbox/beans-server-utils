util.AddNetworkString("bsu_request_groups")

net.Receive("bsu_request_groups", function(_, ply)
	local check = BSU.CheckPlayerPrivilege(ply:SteamID(), BSU.PRIV_MISC, "bsu_groups_view")
	if check == false or check == nil and not ply:IsAdmin() then return end
		local allGroups = BSU.GetAllGroups()

	net.Start("bsu_request_groups")
	net.WriteUInt(#allGroups, 8) -- 0-255
	for _, v in ipairs(allGroups) do
		net.WriteString(v.id)
		net.WriteInt(v.team, 9) -- are team IDs unsigned? (-255 to 255)
		net.WriteString(v.usergroup)
		net.WriteString(v.inherit)
	end
	net.Send(ply)
end)
