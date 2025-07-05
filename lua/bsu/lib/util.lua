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

function BSU.SteamIDToAccount(id)
	local y, z = string.match(id, "^STEAM_0:([01]):(%d+)$")
	if not y then return 0 end
	return bit.lshift(z, 1) + y
end

function BSU.SteamIDFromAccount(acc)
	local y, z = bit.band(acc, 1), bit.rshift(acc, 1)
	return string.format("STEAM_0:%u:%u", y, z)
end

function BSU.SteamID64ToAccount(id64)
	local id = util.SteamIDFrom64(id64)
	return BSU.SteamIDToAccount(id)
end

function BSU.SteamID64FromAccount(acc)
	local id = BSU.SteamIDFromAccount(acc)
	return util.SteamIDTo64(id)
end

-- checks if a string is a valid STEAM_0 or 64 bit steam id (also returns if it was 64 bit or not)
function BSU.IsValidSteamID(steamid)
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

local timesInMins = {
	{ "year", 525600 },
	{ "week", 10080 },
	{ "day", 1440 },
	{ "hour", 60 },
	{ "minute", 1 }
}

-- convert minutes into a nice time format
-- set ratio to the multiplier needed for the amt to stop being counted
-- (ratio used for cases when the input is really big to the point where smaller times like hours or minutes don't really matter)
function BSU.StringTime(mins, ratio)
	local strs = {}

	local max
	for _, data in ipairs(timesInMins) do
		local len = data[2]
		if mins >= len then
			local timeConvert = math.floor(mins / len)
			if timeConvert == math.huge then
				table.insert(strs, "a really long time")
				break
			end
			if ratio and max and max / mins >= ratio then break end
			if not max then max = mins end
			mins = mins % len
			table.insert(strs, string.format("%i %s%s", timeConvert, data[1], timeConvert > 1 and "s" or ""))
		end
	end

	return #strs > 1 and (table.concat(strs, ", ", 1, #strs - 1) .. (#strs == 2 and " and " or ", and ") .. strs[#strs]) or strs[1]
end

-- given a string, finds a var from the global namespace (thanks ULib)
function BSU.FindVar(path, root)
	root = root or _G

	local tableCrumbs = string.Explode("[%.%[]", path, true)
	local len = #tableCrumbs
	for i = 1, len do
		local new, replaced = string.gsub(tableCrumbs[i], "]$", "")
		if replaced > 0 then tableCrumbs[i] = tonumber(new) or new end
	end

	-- navigating
	for i = 1, len - 1 do
		root = root[tableCrumbs[i]]
		if not root or type(root) ~= "table" then return end
	end

	return root[tableCrumbs[len]], root, tableCrumbs[len]
end

-- holds detour data
BSU._detours = BSU._detours or {}
BSU._detour_nodes = BSU._detour_nodes or {}

local function GetDetourData(root, path)
	local func, tbl, key = BSU.FindVar(path, root)
	if not isfunction(func) then return end -- function not found
	local data = BSU._detours[func]
	if not data then -- setup function for detour
		data = { exec = func, nodes = { { exec = func, nodes = {} } }, orig = func, tbl = tbl, key = key }
		func = function(...) return data.exec(...) end
		tbl[key] = func
		BSU._detours[func] = data
	end
	return data, func
end

local function BuildDetourChain(nodes)
	local chain
	for i = 1, #nodes do
		local node = nodes[i]
		local exec = node.exec
		local inner_nodes = node.nodes
		if #inner_nodes > 0 then
			local inner_chain = BuildDetourChain(inner_nodes)
			chain = function(...) return exec({ ... }, inner_chain(...)) end
		elseif chain then
			local prev = chain
			chain = function(...) return exec(prev(...)) end
		else
			chain = exec
		end
	end
	return chain
end

local function RemoveDetourNode(nodes, target)
	for i = 1, #nodes do
		local node = nodes[i]
		local inner_nodes = node.nodes
		local num = #inner_nodes
		if node == target then
			table.remove(nodes, i)
			-- "unwrap" the inner nodes
			if num > 0 then
				-- shift "after" nodes
				for j = i, #nodes do
					nodes[j + num] = nodes[j]
				end
				-- add inner nodes where the target was
				for j = 1, num do
					nodes[j + i - 1] = inner_nodes[j]
				end
			end
			return
		elseif num > 0 then
			RemoveDetourNode(inner_nodes, target)
		end
	end
end

local function FindDetourNode(data, name)
	return BSU._detour_nodes[data] and BSU._detour_nodes[data][name]
end

local function AddDetourLookup(data, name, node)
	if not BSU._detour_nodes[data] then BSU._detour_nodes[data] = {} end
	BSU._detour_nodes[data][name] = node
end

local function RemoveDetourLookup(data, name)
	if BSU._detour_nodes[data] then
		BSU._detour_nodes[data][name] = nil
		if next(BSU._detour_nodes[data]) == nil then
			BSU._detour_nodes[data] = nil
		end
	end
end

local function AddDetourNode(root, path, name, func, method)
	local data, dfunc = GetDetourData(root, path)
	if not data then return end

	local nodes = data.nodes

	-- remove detour if it already exists
	local old_node = FindDetourNode(data, name)
	if old_node then RemoveDetourNode(nodes, old_node) end

	local node

	if method == "before" then
		for i = #nodes, 1, -1 do
			nodes[i + 1] = nodes[i]
		end
		node = { exec = func, nodes = {} }
		nodes[1] = node
	elseif method == "after" then
		node = { exec = func, nodes = {} }
		nodes[#nodes + 1] = node
	elseif method == "wrap" then
		node = { exec = func, nodes = nodes }
		nodes = { node }
		data.nodes = nodes
	else
		error("Unknown detour method: " .. method)
	end

	data.exec = BuildDetourChain(nodes)

	AddDetourLookup(data, name, node)

	return dfunc
end

-- insert a detour before the function and any added detours
-- returns the detoured function, which can be used to remove the detour
-- NOTE: arguments will be what the function/previous detour returned
-- NOTE: return value can be nil to not alter the previous function's return values or a table of values to return instead
function BSU.DetourBefore(...)
	local root, path, name, func
	if istable(...) then
		root, path, name, func = ...
	else
		root, path, name, func = _G, ...
	end

	local call = func
	func = function(...)
		local ret = call(...)
		if ret then return unpack(ret) end
		return ...
	end

	return AddDetourNode(root, path, name, func, "before")
end

-- insert a detour after the function and any added detours
-- returns the detoured function, which can be used to remove the detour
-- NOTE: arguments will be what the function/previous detour returned
-- NOTE: return value can be nil to not alter the previous function's return values or a table of values to return instead
function BSU.DetourAfter(...)
	local root, path, name, func
	if istable(...) then
		root, path, name, func = ...
	else
		root, path, name, func = _G, ...
	end

	local call = func
	func = function(...)
		local ret = call(...)
		if ret then return unpack(ret) end
		return ...
	end

	return AddDetourNode(root, path, name, func, "after")
end

-- insert a detour that wraps around the function and any added detours
-- returns the detoured function, which can be used to remove the detour
-- NOTE: first argument will be a table of the arguments passed to the function, remaining arguments will be what the function returned
-- NOTE: return value can be nil to not alter the previous function's return values or a table of values to return instead
function BSU.DetourWrap(...)
	local root, path, name, func
	if istable(...) then
		root, path, name, func = ...
	else
		root, path, name, func = _G, ...
	end

	local call = func
	func = function(...)
		local ret = call(...)
		if ret then return unpack(ret) end
		return ...
	end

	return AddDetourNode(root, path, name, func, "wrap")
end

-- remove a detour using the detoured function (returned by the BSU.Detour<Method> functions)
function BSU._RemoveDetour(dfunc, name)
	local data = BSU._detours[dfunc]
	if not data then return end

	local node = FindDetourNode(data, name)
	if not node then return end

	local nodes = data.nodes

	RemoveDetourNode(nodes, node)
	RemoveDetourLookup(data, name)

	data.exec = BuildDetourChain(nodes)
end

-- remove a detour on a given root and path by name
-- NOTE: if another addon detoured the function afterwards, this will not work
function BSU.RemoveDetour(...)
	local root, path, name
	if istable(...) then
		root, path, name = ...
	else
		root, path, name = _G, ...
	end

	BSU._RemoveDetour(BSU.FindVar(path, root), name)
end

-- remove all detours using the detoured function, and optionally restore the original function
-- NOTE: if another addon detoured the function afterwards, restoring the original function will also remove its detour
function BSU._ClearDetours(dfunc, restore)
	local data = BSU._detours[dfunc]
	if not data then return end

	BSU._detour_nodes[data] = nil

	local orig = data.orig
	if restore then -- remove all detours and restore the original function
		data.tbl[data.key] = orig
		BSU._detours[dfunc] = nil
	else -- remove all detours but keep the modified function
		data.exec = orig
		data.nodes = { { exec = orig, nodes = {} } }
	end
end

-- remove all detours on a given root and path, and optionally restore the original function
-- NOTE: if another addon detoured the function at the path afterwards, this will not work
function BSU.ClearDetours(...)
	local root, path, restore
	if istable(...) then
		root, path, restore = ...
	else
		root, path, restore = _G, ...
	end

	BSU._ClearDetours(BSU.FindVar(path, root), restore)
end

local color_default = Color(150, 210, 255)

-- tries to fix args for MsgC to appear as it would with chat.AddText
function BSU.FixMsgCArgs(...)
	local args, lastColor = {}, color_default

	for _, v in ipairs({ ... }) do
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

local function RemoveByClass(class)
	for _, ent in ipairs(ents.FindByClass(class)) do
		ent:Remove()
	end
end

function BSU.RemoveClientProps(plys)
	if SERVER then
		BSU.ClientRPC(plys, "BSU.RemoveClientProps")
		RemoveByClass("raggib") -- VALVE 20TH ANNIVERSARY BABY!!!!!!!!!!!!!!!!!
		return
	end
	RemoveByClass("class C_PhysPropClientside")
	RemoveByClass("20C_PhysPropClientside")
end

function BSU.RemoveClientRagdolls(plys)
	if SERVER then
		BSU.ClientRPC(plys, "BSU.RemoveClientRagdolls")
		return
	end
	RemoveByClass("class C_ClientRagdoll")
	RemoveByClass("15C_ClientRagdoll")
end

function BSU.RemoveClientRopes(plys)
	if SERVER then
		BSU.ClientRPC(plys, "BSU.RemoveClientRopes")
		return
	end
	RemoveByClass("class C_RopeKeyframe")
end

function BSU.RemoveClientEffects(plys)
	if SERVER then
		BSU.ClientRPC(plys, "BSU.RemoveClientEffects")
		return
	end
	RemoveByClass("class CLuaEffect")
	RemoveByClass("10CLuaEffect")
end
