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
		if string.sub(text, 1, #prefixSilent) ~= prefixSilent then return hook.Run("BSU_ChatCommand", ply) end
		silent = true
	end

	local split = string.Split(text, " ")
	local name = string.sub(table.remove(split, 1), #(silent and prefixSilent or prefix) + 1)
	local argStr = table.concat(split, " ")

	local cmd = BSU.SafeGetCommandByName(ply, name)

	if cmd then -- check if command exists serverside then run it (and player should be able to see and run it)
		silent = silent or cmd:GetSilent()
		BSU.RunCommand(ply, name, argStr, silent)
	else -- tell client to try run it
		BSU.SendRunCommand(ply, name, argStr, silent)
	end

	local str = hook.Run("BSU_ChatCommand", ply, name, argStr, silent)
	if str then return str end

	if silent then return "" end
end

hook.Add("PlayerSay", "BSU_ChatCommand", chatCommand)

local function sendCommandData(ply)
	BSU.StartRPC("BSU.RegisterServerCommand")
	for _, v in ipairs(BSU.GetCommandList()) do
		if v:GetAccess() ~= BSU.CMD_CONSOLE then
			BSU.AddArgsRPC(v:GetName(), v:GetDescription(), v:GetCategory(), v:GetArgs())
		end
	end
	BSU.FinishRPC(ply)
end

hook.Add("BSU_ClientReady", "BSU_SendCommandData", sendCommandData)
