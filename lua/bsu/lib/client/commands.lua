-- lib/client/commands.lua

function BSU.RunCommand(name, argStr, silent)
	local ply = LocalPlayer()

	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if not cmd then error("Command '" .. name .. "' does not exist") end

	local handler = BSU.CommandHandler(ply, name, argStr, silent)

	xpcall(cmd:GetFunction(), function(err) BSU.SendChatMsg(ply, BSU.CLR_ERROR, "Command errored with: " .. string.Split(err, ": ")[2]) end, handler)
end

function BSU.SafeRunCommand(name, argStr, silent)
	if not BSU.GetCommandByName(name) then BSU.SendConMsg(color_white, "Unknown BSU command: '" .. name .. "'") return end
	BSU.RunCommand(name, argStr, silent)
end

local function callback(self)
	net.Start("bsu_command")
		net.WriteString(self:GetName())
		net.WriteString(self:GetRawMultiStringArg(1, -1) or "")
		net.WriteBool(self:GetSilent())
	net.SendToServer()
end

function BSU.RegisterServerCommand(name, description, category)
	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if cmd and not cmd._serverside then return end -- clientside command already exists

	cmd = BSU.Command(name, description, category, nil, callback)
	cmd._serverside = true

	BSU.RegisterCommand(cmd)
end