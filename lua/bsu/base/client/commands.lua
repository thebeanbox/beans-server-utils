-- base/client/commands.lua

-- create the concommand
concommand.Add("bsu",
	function(_, _, args, argStr)
		local name = args[1]
		if not name then return end
		local cmd = BSU.GetCommandByName(name)

		if cmd and not cmd.serverside then
			BSU.RunCommand(name, string.sub(argStr, #name + 2)) -- run clientside command
		else
			LocalPlayer():ConCommand("_bsu " .. argStr) -- try to run serverside command
		end
	end,
	function(_, strargs)
		local args = string.Explode(" ", strargs)
		table.remove(args, 1)
		local name = args[1]
		if not name then return end
		local bsucmd = BSU.GetCommandByName(name)

		if bsucmd then
			-- TODO: Autocomplete/suggest args
			return {}
		else
			local autocomplete = {}
			local names = {}
			for k, _ in pairs(BSU._cmds) do
				if name == string.sub(k, 1, #name) then
					table.insert(names, k)
				end
			end
			table.sort(names, function(a, b)
				return #a < #b
			end)
			for _, v in ipairs(names) do
				table.insert(autocomplete, "bsu " .. v)
			end
			return autocomplete
		end
	end
)

-- allow clientside command usage in chat
local function runChatCommand(ply, text)
	if ply ~= LocalPlayer() then return end

	if not string.StartWith(text, BSU.CMD_PREFIX) then return end

	local split = string.Split(text, " ")
	local name = string.lower(string.sub(table.remove(split, 1), 2))
	local argStr = table.concat(split, " ")

	local cmd = BSU.GetCommandByName(name)

	if cmd and not cmd.serverside then
		BSU.RunCommand(name, argStr)
	end
end

hook.Add("OnPlayerChat", "BSU_RunChatCommand", runChatCommand)
