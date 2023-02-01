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
	function(_, args)
		--[[local name = args[1]
		if not name then return end
		local cmd = BSU.GetCommandByName(name)
		
		if cmd then
			return {}
		else
			local autocomplete = {}
			local names = {}
			-- this don't work, pls fix
			for _, v in ipairs(table.GetKeys(BSU._cmds)) do
				if v == string.sub(name, 0, #v) then
					table.insert(names, v)
				end
			end
			table.sort(names, function(a, b) return #a <= #b end)
			for _, v in ipairs(names) do
				table.insert("bsu " .. v)
			end
			return autocomplete
		end]]
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