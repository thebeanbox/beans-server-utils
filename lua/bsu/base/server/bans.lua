-- base/server/bans.lua
-- handles player bans

-- check if player is banned and prevent them from joining when attempting to connect
local function passwordBanCheck(steamid, ip)
	local success, callback, reason = xpcall(
		function()
			local ban = BSU.GetBanStatus(steamid) -- check for any bans on the steam id
			if not ban then
				ban = BSU.GetBanStatus(ip) -- check for any bans on the ip
			end
			if ban then
				return false, BSU.FormatBanMsg(ban.reason, ban.duration, ban.time, BSU.GetPDataBySteamID(steamid, "timezone"))
			end
		end,
		function(err)
			return err
		end
	)

	-- if for some reason an error occurs while getting the ban data, then kick the client just to be safe (this should hopefully never happen)
	-- without this a banned player will be able to join if an error occurs
	if success then
		return callback, reason
	else
		steamid = util.SteamIDFrom64(steamid)
		MsgN("Error while ban checking client (" .. steamid .. "): " .. callback)
		return false, "Oops! Something bad happened...\n\nAn error occurred while authenticating you:\n\n" .. callback .. "\n\nKicking the client (" .. steamid .. ") just to be safe."
	end
end

hook.Add("CheckPassword", "BSU_PasswordBanCheck", passwordBanCheck)

local allowFamilySharing = GetConVar("bsu_allow_family_sharing")

-- permaban players using family share to ban evade
local function familyShareBanCheck(_, steamid, ownerid64)
	local steamid64 = BSU.ID64(steamid)

	if steamid64 ~= ownerid64 then -- this player doesn't own the Garry's Mod license they're using
		local ban = BSU.GetBanStatus(ownerid64)
		if ban then -- if the owner of the license is banned
			BSU.BanSteamID(steamid64, string.format("%s (Steam Family Sharing with banned account: %s)", ban.reason or "No reason given", util.SteamIDFrom64(ownerid64)))
		elseif not allowFamilySharing:GetBool() then
			game.KickID(steamid, "Steam Family Sharing is prohibited on this server")
		end
	end
end

hook.Add("NetworkIDValidated", "BSU_FamilyShareBanCheck", familyShareBanCheck)
