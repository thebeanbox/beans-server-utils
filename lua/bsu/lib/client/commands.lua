-- lib/client/commands.lua

local function run(cmd, handler)
	cmd:GetFunction()(handler, handler:GetCaller(), handler:GetArgs())
end

function BSU.RunCommand(name, argStr, silent)
	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if not cmd then error("Command '" .. name .. "' does not exist") end

	local handler = BSU.CommandHandler(LocalPlayer(), cmd, argStr, silent)

	xpcall(run, function(err) handler:PrintErrorMsg("Command errored with: " .. string.Split(err, ": ")[2]) end, cmd, handler)
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
	BSU.SendRunCommand(self.cmd.name, table.concat(self.args, " "), self.silent)
end

function BSU.RegisterServerCommand(name, desc, category, args)
	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if cmd and not cmd._serverside then return end -- clientside command already exists

	cmd = BSU.Command(name, desc, category)
	cmd.args = args
	cmd.func = callback
	cmd._serverside = true

	BSU.RegisterCommand(cmd)
end