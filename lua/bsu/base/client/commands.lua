-- base/client/commands.lua

local string_format = string.format

local argTypeLookup = {
	[0] = "string",
	[1] = "number",
	[2] = "player",
	[3] = "players",
}

local function autoComplete(concommand, argStr)
	local name = string.match(argStr, "^ ([^%s]+)") or ""
	local cmd = BSU.GetCommandByName(name)

	if cmd then
		local handler = BSU.CommandHandler(LocalPlayer(), cmd, string.sub(argStr, #name + 2), true)

		-- Count number of correct args
		local n = 0
		for i, arg in ipairs(cmd.args) do
			if arg.kind == 0 then
				if not handler:GetStringArg(i) then break end
				n = n + 1
			elseif arg.kind == 1 then
				if not handler:GetNumberArg(i) then break end
				n = n + 1
			elseif arg.kind == 2 then
				if not handler:GetPlayerArg(i) then break end
				n = n + 1
			elseif arg.kind == 3 then
				if not handler:GetPlayersArg(i) then break end
				n = n + 1
			end
		end
		if n >= #cmd.args then return end

		-- formatting magic
		local template = string_format("%s %s %s%%s", concommand, name, n > 0 and table.concat(handler.args, " ", 1, n) .. " " or "")

		-- Arg list
		local argTypes = {}
		for i = n + 1, #cmd.args do
			local arg = cmd.args[i]
			table.insert(argTypes, string_format("<%s: %s>", arg.name, argTypeLookup[arg.kind]))
		end
		local argFiller = string_format(template, table.concat(argTypes, " "))

		-- Custom autocomplete table.
		-- Probably add support for a function later.
		local arg = cmd.args[n + 1]

		local autocomplete = arg.autocomplete
		if autocomplete then
			local suggestions = { argFiller }
			for _, v in ipairs(autocomplete) do
				table.insert(suggestions, string_format(template, string_format("\"%s\"", v)))
			end

			return suggestions
		end

		-- Player suggestions
		if arg.kind == 2 or arg.kind == 3 then
			local suggestions = { argFiller }

			local plyName = string.gsub(string.lower(handler.args[n + 1] or ""), "^\"", "")

			for _, v in ipairs(player.GetAll()) do
				if plyName == string.sub(string.lower(v:Nick()), 1, #plyName) then
					table.insert(suggestions, string_format(template, string_format("\"%s\"", v:Nick())))
				end
			end

			return suggestions
		end

		return { argFiller }
	else
		local result, names = {}, {}

		for _, v in ipairs(BSU.GetAllCommandNames()) do
			if name == string.sub(v, 1, #name) then
				table.insert(names, v)
			end
		end
		table.sort(names, function(a, b) return #a < #b end)

		for _, v in ipairs(names) do
			table.insert(result, string_format("%s %s", concommand, v))
		end

		return result
	end
end

-- concommand for using commands
concommand.Add(BSU.CMD_CONCMD, function(_, _, args, argStr)
	if not args[1] then return end
	local name = string.lower(args[1])
	BSU.SafeRunCommand(name, string.sub(argStr, #name + 2))
end, autoComplete)

-- concommand for using commands silently
concommand.Add(BSU.CMD_CONCMD_SILENT, function(_, _, args, argStr)
	if not args[1] then return end
	local name = string.lower(args[1])
	BSU.SafeRunCommand(name, string.sub(argStr, #name + 2), true)
end, autoComplete)

