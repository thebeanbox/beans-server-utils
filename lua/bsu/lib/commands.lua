-- lib/commands.lua (SHARED)

local groupChars = {
	'"',
	"'"
}

-- parse a string to command arguments (set inclusive to true to leave the group chars in the result)
local function parseArgs(input, inclusive)
	local index, args = 1, {}

	while true do
		local str = string.sub(input, index)

		-- look for group chars
		local foundGroupChars = {}
		for i = 1, #groupChars do
			local char = groupChars[i]
			local pos = string.find(str, char, 1, true)
			if pos then
				table.insert(foundGroupChars, { char, pos })
			end
		end

		local found

		if next(foundGroupChars) ~= nil then
			table.sort(foundGroupChars, function(a, b) return a[2] < b[2] end)

			for i = 1, #foundGroupChars do
				local char, pos1 = unpack(foundGroupChars[i])
				local pos2 = string.find(str, char, pos1 + 1, true)
				if pos2 then
					-- add before args separated by spaces
					local split = string.Split(string.sub(str, 1, pos1 - 1), " ")
					if args[#args] then
						args[#args] = args[#args] .. table.remove(split, 1) -- append first string to last arg
					end
					table.Add(args, split) -- add the rest

					args[#args] = args[#args] .. string.sub(str, pos1 + (inclusive and 0 or 1), pos2 - (inclusive and 0 or 1)) -- append string to last arg
					index = index + pos2
					found = true
					break
				end
			end
		end

		if found then continue end

		-- add args separated by spaces
		local split = string.Split(str, " ")
		if args[#args] then
			args[#args] = args[#args] .. table.remove(split, 1) -- append first string to last arg
		end
		table.Add(args, split) -- add the rest
		break
	end

	-- remove any empty string args
	local newArgs = {}
	for i = 1, #args do
		local arg = args[i]
		if arg ~= "" then
			table.insert(newArgs, arg)
		end
	end

	return newArgs
end

-- returns table of players via prefixed command argument
-- returns empty table if failed to retrieve (ex: invalid player name, invalid player steamid, invalid group name, or no prefixes matched)
local function parsePlayerArg(user, str)
	if str == "^" then -- player who ran the command
		if user:IsValid() then -- user can be NULL if executed from the server console
			return { user }
		end
		return {}
	elseif str == "*" then -- wildcard (all players)
		return player.GetAll()
	else
		local pre = string.sub(str, 1, 1)
		local val = string.sub(str, 2)
		if pre == "@" then -- specific player
			val = parseArgs(val)[1]
			if val then -- get by player name
				val = string.lower(val)
				for _, v in ipairs(player.GetAll()) do
					if val == string.lower(v:GetName()) then
						return { v }
					end
				end
			elseif user:IsValid() then -- get by eye trace
				local ent = user:GetEyeTrace().Entity
				if ent:IsPlayer() then
					return { ent }
				end
			end
			return {}
		elseif pre == "$" then -- player by steamid
			val = parseArgs(val)[1]
			if BSU.IsValidSteamID(val) then
				local ply = player.GetBySteamID64(BSU.ID64(val))
				if ply ~= false and ply:IsValid() then
					return { ply }
				end
				return {}
			end
		elseif pre == "#" then -- players by team name
			val = parseArgs(val)[1]

			local plys = {}
			for _, v in ipairs(player.GetAll()) do
				if val == team.GetName(v:Team()) then
					table.insert(plys, v)
				end
			end

			return plys
		elseif pre == "!" then -- opposite of next prefix
			local result = parsePlayerArg(user, val)

			-- create lookup table from result
			local list = {}
			for i = 1, #result do
				list[result[i]] = true
			end

			-- get all players not in the lookup table
			local plys = {}
			for _, v in ipairs(player.GetAll()) do
				if not list[v] then
					table.insert(plys, v)
				end
			end

			return plys
		end
	end

	-- check if the argument matches player names
	local nameArg, plys = string.lower(parseArgs(str)[1]), {}

	for _, v in ipairs(player.GetAll()) do
		local name = string.lower(v:GetName())
		if nameArg == name then -- found exact name
			return { v }
		elseif #nameArg >= 3 then -- must be a minimum of 3 characters for partial search
			if string.find(name, nameArg, 1, true) then
				table.insert(plys, v)
			end
		end
	end

	return plys
end

-- holds command objects
BSU._cmds = BSU._cmds or {}

-- command object
local objCommand = {}
objCommand.__index = objCommand
objCommand.__tostring = function(self) return "BSU Command[" .. self.name .. "]" end

-- command object setters

function objCommand.SetDescription(self, desc)
	self.description = desc and tostring(desc) or ""
end

function objCommand.SetCategory(self, category)
	self.category = category and string.lower(category) or "misc"
end

function objCommand.SetAccess(self, access) -- only used serverside, is pointless clientside but kept for shared scripts
	self.access = access or BSU.CMD_ANYONE
end

function objCommand.SetFunction(self, func)
	self.func = func
end

function objCommand.AddArgumentsOption(self, str)
	table.insert(self.options, str)
end

-- command object getters

function objCommand.GetName(self)
	return self.name
end

function objCommand.GetDescription(self)
	return self.description
end

function objCommand.GetCategory(self)
	return self.category
end

function objCommand.GetAccess(self) -- only used serverside, is pointless clientside but kept for shared scripts
	return self.access
end

function objCommand.GetFunction(self)
	return self.func
end

-- create a command object
function BSU.Command(name, description, category, access, func)
	return setmetatable({
		name = string.lower(name),
		description = description or "",
		category = category or "misc",
		access = access or BSU.CMD_ANYONE,
		func = func or function() end
	}, objCommand)
end

function BSU.RegisterCommand(cmd)
	BSU._cmds[string.lower(cmd:GetName())] = cmd
end

function BSU.SetupCommand(name, setup)
	local cmd = BSU.Command(name)
	if setup then setup(cmd) end
	BSU.RegisterCommand(cmd)
end

function BSU.AliasCommand(alias, original)
	local originalCmd = BSU._cmds[string.lower(original)]
	local aliasCmd = BSU.Command(
		alias,
		"Alias of " .. string.lower(original),
		originalCmd:GetCategory(),
		SERVER and originalCmd:GetAccess() or nil,
		originalCmd:GetFunction()
	)
	BSU.RegisterCommand(aliasCmd)
end

function BSU.GetCommands()
	return table.ClearKeys(BSU._cmds)
end

function BSU.GetCommandNames()
	return table.GetKeys(BSU._cmds)
end

function BSU.GetCommandByName(name)
	return BSU._cmds[string.lower(name)]
end

function BSU.GetCommandsByCategory(category)
	local list = {}
	for _, v in pairs(BSU._cmds) do
		if v.category == category then
			table.insert(list, v)
		end
	end
	return list
end

function BSU.GetCommandCategories()
	local seen = {}
	for _, v in pairs(BSU._cmds) do
		local category = v.category
		if not seen[category] then
			seen[category] = true
		end
	end
	return table.GetKeys(seen)
end

function BSU.GetCommandsByAccess(access)  -- only used serverside, is pointless clientside but kept for shared scripts
	local list = {}
	for _, v in pairs(BSU._cmds) do
		if v.access == access then
			table.insert(list, v)
		end
	end
	return list
end

-- command handler object
local objCmdHandler = {}
objCmdHandler.__index = objCmdHandler
objCmdHandler.__tostring = function(self) return "BSU Command Handler[" .. self.name .. "]" end

function objCmdHandler.GetName(self)
	return self.name
end

function objCmdHandler.GetSilent(self)
	return self.silent
end

function objCmdHandler.GetCaller(self, fail)
	if fail and not self.caller:IsValid() then
		error("Unable to find player who called the command (was ran from server console?)")
	end
	return self.caller
end

local function errorBadArgument(num, reason)
	error("Bad argument #" .. num .. " (" .. reason .. ")")
end

-- used for getting the original string of the argument
function objCmdHandler.GetRawStringArg(self, n, fail)
	local arg = self.args[n]
	if arg then
		return arg
	elseif fail then
		errorBadArgument(n, "expected string, found nothing")
	end
end

-- used for getting the string of the argument but parsed
function objCmdHandler.GetStringArg(self, n, fail)
	local str = self:GetRawStringArg(n, fail)
	if str then
		return parseArgs(str)[1]
	elseif fail then
		errorBadArgument(n, "expected string, found nothing")
	end
end

-- used for getting multiple original string arguments as a single string
function objCmdHandler.GetRawMultiStringArg(self, n1, n2, fail)
	if n1 < 0 then
		n1 = #self.args + n1 + 1
	end
	if n2 then
		if n2 < 0 then
			n2 = #self.args + n2 + 1
		end
	else
		n2 = #self.args
	end

	if n1 ~= n2 then -- get unparsed arguments from n1 to n2
		local str
		for i = n1, n2 do
			local arg = self.args[i]
			if arg then
				if not str then
					str = arg
				else
					str = str .. " " .. arg
				end
			else
				break
			end
		end
		if str then
			return str
		elseif fail then
			errorBadArgument(n1, "expected string, found nothing")
		end
	end
	local arg = self.args[n1]
	if arg then
		return arg
	elseif fail then
		errorBadArgument(n1, "expected string, found nothing")
	end
end

-- used for getting multiple parsed string arguments as a single string
function objCmdHandler.GetMultiStringArg(self, n1, n2, fail)
	local str = self:GetRawMultiStringArg(n1, n2, fail)
	if str then
		return table.concat(parseArgs(str), " ") -- parse and concat back to string
	elseif fail then
		errorBadArgument(n1, "expected string, found nothing")
	end
end

-- used for getting an argument parsed as a number (will fail if it couldn't be converted to a number)
function objCmdHandler.GetNumberArg(self, n, fail)
	local arg = self.args[n]
	if arg then
		local val = tonumber(arg)
		if val then
			return val
		elseif fail then
			errorBadArgument(n, "failed to interpret '" .. arg .. "' as a number")
		end
	elseif fail then
		errorBadArgument(n, "expected number, got nothing")
	end
end

-- used for getting an argument parsed as a target (will fail if none or more than 1 targets are found)
function objCmdHandler.GetPlayerArg(self, n, fail)
	local arg = self.args[n]
	if arg then
		local plys = parsePlayerArg(self.caller, arg)
		if #plys == 1 then
			local ply = plys[1]
			if ply:IsValid() then
				return ply
			elseif fail then
				errorBadArgument(n, "target was invalid")
			end
		elseif fail then
			if next(plys) == nil then
				errorBadArgument(n, "failed to find a target")
			else
				errorBadArgument(n, "received too many targets")
			end
		end
	elseif fail then
		errorBadArgument(n, "expected target, found nothing")
	end
end

-- used for getting an argument parsed as 1 or more targets (will fail if none are found)
function objCmdHandler.GetPlayersArg(self, n, fail)
	local arg = self.args[n]
	if arg then
		local plys = parsePlayerArg(self.caller, arg)
		if next(plys) ~= nil then
			return plys
		elseif fail then
			errorBadArgument(n, "failed to find any targets")
		end
	elseif fail then
		errorBadArgument(n, "expected targets, found nothing")
	end
end

if SERVER then
	function objCmdHandler.CheckCanTargetSteamID(self, targetID, fail)
		targetID = BSU.ID64(targetID)
		if not self.caller:IsValid() or self.caller:IsSuperAdmin() or self.caller:SteamID64() == targetID then return true end
		local targetPriv = BSU.CheckPlayerPrivilege(self.caller:SteamID64(), BSU.PRIV_TARGET, BSU.GetPlayerDataBySteamID(targetID).groupid)
		if targetPriv then return true end
		if fail then error("You cannot select this target") end
		return false
	end

	function objCmdHandler.CheckCanTarget(self, target, fail)
		if not self.caller:IsValid() or self.caller:IsSuperAdmin() or self.caller == target then return true end -- is server console or superadmin
		return self:CheckCanTargetSteamID(target:SteamID64(), fail)
	end

	function objCmdHandler.FilterTargets(self, targets, exclude, fail)
		local tbl = {}
		for _, tar in ipairs(targets) do
			if tar:IsValid() and not (exclude and tar == self.caller) and self:CheckCanTarget(tar) then
				table.insert(tbl, tar)
			end
		end
		if next(tbl) == nil and fail then
			error("You cannot select " .. (#targets == 1 and "this target" or "these targets"))
		end
		return tbl
	end

	local function formatArg(ply, target, arg)
		local vars = {}
		if istable(arg) then
			local totalPlys = 0
			for _, v in ipairs(arg) do
				if isentity(v) and v:IsPlayer() then
					totalPlys = totalPlys + 1
				end
			end
			if totalPlys == #player.GetAll() then
				table.Add(vars, { BSU.CLR_EVERYONE, "Everyone" })
			else
				for k, v in ipairs(arg) do -- expect table arg to be sequential
					if not istable(v) then continue end -- ignore tables in table arg (can cause weird formatting or infinite recursion)
					if k > 1 then
						table.Add(vars, { BSU.CLR_TEXT, k < #arg and ", " or (#arg > 2 and ", and " or " and ") })
					end
					table.Add(vars, formatArg(ply, target, v))
				end
			end
		elseif isentity(arg) then
			if arg:IsPlayer() then
				table.Add(vars, arg == ply and (arg == target and { BSU.CLR_SELF, "Yourself" } or { BSU.CLR_SELF, "Themself" }) or { arg })
			else
				table.Add(vars, { BSU.CLR_MISC, tostring(arg) })
			end
		else
			table.Add(vars, { BSU.CLR_PARAM, tostring(arg) })
		end
		return vars
	end

	local function formatActionMsg(ply, target, msg, args)
		local vars = {}
		local pos = 1

		for pre, name in string.gmatch(msg, "(.-)%%([%w_]+)%%") do
			table.Add(vars, { BSU.CLR_TEXT, pre })

			local arg = args[name]
			if arg ~= nil then
				table.Add(vars, formatArg(ply, target, arg))
			elseif name == "caller" then
				table.Add(vars, ply:IsValid() and (ply == target and { BSU.CLR_SELF, "You" } or { ply }) or { BSU.CLR_CONSOLE, "(Console)" })
			end

			pos = pos + #pre + #name + 2
		end

		local last = string.sub(msg, pos)
		if #last > 0 then -- add last part of the msg
			table.Add(vars, { BSU.CLR_TEXT, last })
		end

		return unpack(vars)
	end

	-- sends a message in everyone's chat and formats player entities and tables of player entities
	function objCmdHandler.BroadcastActionMsg(self, msg, args)
		if self.silent then msg = "(SILENT) " .. msg end
		for _, v in ipairs(player.GetHumans()) do
			local val = hook.Run("BSU_ShowActionMessage", self.caller, v, self.silent) -- expects nil for default behavior, 2 for chat, 1 for console, 0 or anything else for hidden
			if val == nil and (not self.silent or (v:IsSuperAdmin() or v == self.caller)) or val == 2 then
				BSU.SendChatMsg(v, formatActionMsg(self.caller, v, msg, args))
			elseif val == 1 then
				BSU.SendConMsg(v, formatActionMsg(self.caller, v, msg, args))
			end -- 0 or anything else for hidden
		end
		BSU.SendChatMsg(NULL, formatActionMsg(self.caller, NULL, msg, args)) -- send msg to server console
	end
end

-- sends a message to the player in console (will print into the server console if the command was ran through it)
function objCmdHandler.SendConMsg(self, ...)
	if SERVER and self.caller:IsValid() then
		BSU.SendConMsg(self.caller, ...)
	else -- cmd was ran through the server console
		MsgC(...)
		MsgN()
	end
end

-- sends a message to the player in chat (will print into the server console if the command was ran through it)
function objCmdHandler.SendChatMsg(self, ...)
	if SERVER then
		if self.caller:IsValid() then -- cmd was ran through the server console
			BSU.SendChatMsg(self.caller, ...)
		else -- cmd was ran through the server console
			MsgC(...)
			MsgN()
		end
	else
		chat.AddText(...)
	end
end

function objCmdHandler.SendErrorMsg(self, err)
	self:SendChatMsg(BSU.CLR_ERROR, err)
end

-- used for a command to check if it should process something on a player
function objCmdHandler.SetExclusive(self, ply, action)
	ply.bsu_exclusive = action
end

function objCmdHandler.CheckExclusive(self, ply, warn)
	if not ply.bsu_exclusive then return true end
	if warn then
		self:SendErrorMsg((ply == self.caller and "You are " or (ply:Nick() .. " is ")) .. ply.bsu_exclusive .. "!")
	end
	return false
end

function objCmdHandler.ClearExclusive(self, ply)
	ply.bsu_exclusive = nil
end

-- create a command handler object
function BSU.CommandHandler(caller, name, argStr, silent)
	return setmetatable({
		caller = caller,
		name = name,
		args = parseArgs(argStr or "", true),
		silent = silent or false
	}, objCmdHandler)
end