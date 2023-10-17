-- lib/util.lua (SHARED)
-- useful functions for both server and client

local color_sv_log = Color(0, 100, 255)
local color_cl_log = Color(255, 100, 0)

-- prints a message into console formatted like "[BSU] bla bla bla" (color depends on realm)
function BSU.Log(msg)
	MsgC(SERVER and color_sv_log or color_cl_log, "[BSU] ", color_white, msg .. "\n")
end

function BSU.ColorToHex(color)
	return string.format("%.2x%.2x%.2x", color.r, color.g, color.b)
end

function BSU.HexToColor(hex, alpha)
	hex = string.gsub(hex, "#", "")
	return Color(tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6)), alpha or 255)
end

BSU.UTCTime = os.time

function BSU.LocalTime()
	return os.time(os.date("!*t"))
end

function BSU.SteamIDTo3(id)
	local y, z = string.match(id, "^STEAM_0:([01]):(%d+)$")
	if not y then return 0 end
	return bit.lshift(z, 1) + y
end

function BSU.SteamIDFrom3(id3)
	local y, z = bit.band(id3, 1), bit.rshift(id3, 1)
	return string.format("STEAM_0:%u:%u", y, z)
end

function BSU.SteamID64To3(id64)
	local id = util.SteamIDFrom64(id64)
	return BSU.SteamIDTo3(id)
end

function BSU.SteamID64From3(id3)
	local id = BSU.SteamIDFrom3(id3)
	return util.SteamIDTo64(id)
end

-- checks if a string is a valid STEAM_0 or 64 bit steam id (also returns if it was 64 bit or not)
function BSU.IsValidSteamID(steamid)
	if not isstring(steamid) then return false end
	if string.match(steamid, "^STEAM_0:[01]:%d+$") then
		return true, false
	elseif string.match(steamid, "^%d+$") then
		return true, true
	end
	return false
end

-- checks if a string is a valid ipv4 address or "loopback" (ignores the port)
function BSU.IsValidIP(ip)
	if not isstring(ip) then return false end
	if ip == "loopback" then return true end -- fix for single-player hosts
	local address = string.Split(ip, ":")[1]
	return string.match(address, "^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?$") ~= nil
end

-- tries to convert a steamid to 64 bit if it's valid
function BSU.ID64(steamid)
	local valid, is64 = BSU.IsValidSteamID(steamid)
	if not valid then return error("Received bad steam id") end
	if is64 then
		return steamid
	else
		return util.SteamIDTo64(steamid)
	end
end

-- tries to remove the port from an ip if it's valid
function BSU.Address(ip)
	if not BSU.IsValidIP(ip) then return error("Received bad ip address") end
	return string.Split(ip, ":")[1]
end

-- tries to correct an identity to be valid (will return a 64 bit id, an ip address, or nil on failure)
function BSU.ValidateIdentity(identity)
	return BSU.IsValidSteamID(identity) and BSU.ID64(identity) or BSU.IsValidIP(identity) and BSU.Address(identity) or nil
end

-- convert minutes into a nice time format
-- set ratio to the multiplier needed for the amt to stop being counted
-- (ratio used for cases when the input is really big to the point where smaller times like hours or minutes don't really matter)
function BSU.StringTime(mins, ratio)
	local strs = {}
	local timesInMins = {
		{ "year", 525600 },
		{ "week", 10080 },
		{ "day", 1440 },
		{ "hour", 60 },
		{ "minute", 1 }
	}

	local max
	for i = 1, #timesInMins do
		local time, len = unpack(timesInMins[i])
		if mins >= len then
			local timeConvert = math.floor(mins / len)
			if timeConvert == math.huge then
				table.insert(strs, "a really long time")
				break
			end
			if ratio and max and max / mins >= ratio then break end
			if not max then max = mins end
			mins = mins % len
			table.insert(strs, string.format("%i %s%s", timeConvert, time, timeConvert > 1 and "s" or ""))
		end
	end

	return #strs > 1 and (table.concat(strs, ", ", 1, #strs - 1) .. (#strs == 2 and " and " or ", and ") .. strs[#strs]) or strs[1]
end

-- given a string, finds a var from the global namespace (thanks ULib)
function BSU.FindVar(location, root)
	root = root or _G

	local tableCrumbs = string.Explode("[%.%[]", location, true)
	for i = 1, #tableCrumbs do
		local new, replaced = string.gsub(tableCrumbs[i], "]$", "")
		if replaced > 0 then tableCrumbs[i] = (tonumber(new) or new) end
	end

	-- navigating
	for i = 1, #tableCrumbs - 1 do
		root = root[tableCrumbs[i]]
		if not root or type(root) ~= "table" then return end
	end

	return root[tableCrumbs[#tableCrumbs]]
end

local color_default = Color(150, 210, 255)

-- tries to fix args for MsgC to appear as it would with chat.AddText
function BSU.FixMsgCArgs(...)
	local args, lastColor = {}, color_default

	for _, v in ipairs({...}) do
		if isentity(v) then
			if not v:IsValid() then
				table.insert(args, "(null)")
			elseif v:IsPlayer() then
				table.Add(args, { team.GetColor(v:Team()), v:Nick(), lastColor })
			else
				table.insert(args, v:GetClass())
			end
		elseif istable(v) then
			local color = Color(v.r or 255, v.g or 255, v.b or 255)
			lastColor = color
			table.insert(args, color)
		elseif isstring(v) then
			table.insert(args, v)
		end
	end

	return unpack(args)
end
