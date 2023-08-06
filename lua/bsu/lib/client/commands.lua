-- lib/client/commands.lua

function BSU.RunCommand(name, argStr, silent)
	local ply = LocalPlayer()

	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if not cmd then error("Command '" .. name .. "' does not exist") end

	local handler = BSU.CommandHandler(ply, name, argStr, silent)

	xpcall(cmd:GetFunction(), function(err) handler:PrintErrorMsg("Command errored with: " .. string.Split(err, ": ")[2]) end, handler)
end

function BSU.SafeRunCommand(name, argStr, silent)
	if not BSU.GetCommandByName(name) then BSU.SendConsoleMsg(color_white, "Unknown BSU command: '" .. name .. "'") return end
	BSU.RunCommand(name, argStr, silent)
end

function BSU.SendRunCommand(name, argStr, silent)
	net.Start("bsu_command_run")
		net.WriteString(name)
		net.WriteString(argStr)
		net.WriteBool(silent)
	net.SendToServer()
end

net.Receive("bsu_command_run", function()
	local name = net.ReadString()
	local argStr = net.ReadString()
	local silent = net.ReadBool()
	BSU.SafeRunCommand(name, argStr, silent)
end)

local function callback(self)
	BSU.SendRunCommand(self:GetName(), self:GetRawMultiStringArg(1) or "", self:GetSilent())
end

function BSU.RegisterServerCommand(name, ...)
	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if cmd and not cmd._serverside then return end -- clientside command already exists

	cmd = BSU.Command(name, ...)
	cmd:SetFunction(callback)
	cmd._serverside = true

	BSU.RegisterCommand(cmd)
end