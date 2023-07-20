-- lib/client/commands.lua

function BSU.RunCommand(name, argStr, silent)
	local ply = LocalPlayer()

	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if not cmd then error("Command '" .. name .. "' does not exist") end

	local handler = BSU.CommandHandler(ply, argStr, silent)

	xpcall(cmd.func, function(err) BSU.SendChatMsg(ply, BSU.CLR_ERROR, "Command errored with: " .. string.Split(err, ": ")[2]) end, handler, ply, name, argStr)
end

function BSU.SafeRunCommand(name, argStr, silent)
	if not BSU.GetCommandByName(name) then BSU.SendConMsg(color_white, "Unknown BSU command: '" .. name .. "'") return end
	BSU.RunCommand(name, argStr, silent)
end

local function callback(self, _, name, argStr)
	net.Start("bsu_command")
		net.WriteString(name)
		net.WriteString(argStr)
		net.WriteBool(self:IsSilent())
	net.SendToServer()
end

function BSU.RegisterServerCommand(name, description, category)
	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if cmd and not cmd.serverside then return end -- clientside command already exists

	cmd = BSU.Command(name, description, category, nil, callback)
	cmd.serverside = true

	BSU.RegisterCommand(cmd)
end