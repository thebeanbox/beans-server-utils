-- base/server/commands.lua

-- create concommand for using commands
concommand.Add("bsu", function(ply, _, args, argStr)
	if not args[1] then return end
	local name = string.lower(args[1])
	BSU.SafeRunCommand(ply, name, string.sub(argStr, #name + 2))
end)

-- create concommand for using commands silently
concommand.Add("sbsu", function(ply, _, args, argStr)
	if not args[1] then return end
	local name = string.lower(args[1])
	BSU.SafeRunCommand(ply, name, string.sub(argStr, #name + 2), true)
end)

-- allow command usage in chat
local function chatCommand(ply, text)
	local silent

	local prefix, prefixSilent = BSU.CMD_PREFIX, BSU.CMD_PREFIX_SILENT

	if string.sub(text, 1, #prefix) ~= prefix then
		if string.sub(text, 1, #prefixSilent) ~= prefixSilent then return end
		silent = true
	end

	local name, argStr = string.match(text, "^(%S+) ?(%S*)")
	name = string.sub(name, #(silent and prefixSilent or prefix) + 1)

	-- yeah i know this looks dumb, but blame Garry for not adding a way to override chat messages clientside before they are sent to the server
	BSU.ClientRPC(ply, "BSU.SafeRunCommand", name, argStr, silent)

	if silent then return "" end
end

hook.Add("PlayerSay", "BSU_ChatCommand", chatCommand)

local function sendCommandData(ply)
	for _, v in ipairs(BSU.GetCommands()) do
		BSU.ClientRPC(ply, "BSU.RegisterServerCommand", v:GetName(), v:GetDescription(), v:GetCategory())
	end
end

hook.Add("BSU_ClientReady", "BSU_SendCommandData", sendCommandData)