-- base/client/commands.lua

local function autoComplete(_, argStr)
	local args = string.Split(string.Trim(argStr), " ")
	local name = table.remove(args, 1)
	if not name then return end

	local cmd = BSU.GetCommandByName(name)

	if cmd then
		-- TODO: Autocomplete/suggest args
		return {}
	else
		local result, names = {}, {}

		for _, v in ipairs(BSU.GetCommandNames()) do
			if name == string.sub(v, 1, #name) then
				table.insert(names, v)
			end
		end
		table.sort(names, function(a, b) return #a < #b end)

		for _, v in ipairs(names) do
			table.insert(result, "bsu " .. v)
		end

		return result
	end
end

-- create concommand for using commands
concommand.Add("bsu", function(_, _, args, argStr)
	if not args[1] then return end
	local name = string.lower(args[1])
	BSU.SafeRunCommand(name, string.sub(argStr, #name + 2))
end, autoComplete)

-- create concommand for using commands silently
concommand.Add("sbsu", function(_, _, args, argStr)
	if not args[1] then return end
	local name = string.lower(args[1])
	BSU.SafeRunCommand(name, string.sub(argStr, #name + 2), true)
end, autoComplete)
