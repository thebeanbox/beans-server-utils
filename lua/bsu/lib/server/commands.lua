-- lib/server/commands.lua

-- set whether a group must or mustn't have access to a command
-- (setting this will ignore the command's access value)
-- (access is granted by default)
function BSU.AddGroupCommandAccess(groupid, cmd, access)
	BSU.RegisterGroupPrivilege(groupid, BSU.PRIV_CMD, string.lower(cmd), access == nil and true or access)
end

-- set whether a player must or mustn't have access to a command
-- (setting this will ignore the command's access value)
-- (access is granted by default)
function BSU.AddPlayerCommandAccess(steamid, cmd, access)
	BSU.RegisterPlayerPrivilege(steamid, BSU.PRIV_CMD, string.lower(cmd), access == nil and true or access)
end

function BSU.RemoveGroupCommandAccess(groupid, cmd)
	BSU.RemoveGroupPrivilege(groupid, BSU.PRIV_CMD, string.lower(cmd))
end

function BSU.RemovePlayerCommandAccess(steamid, cmd)
	BSU.RemovePlayerPrivilege(steamid, BSU.PRIV_CMD, string.lower(cmd))
end

function BSU.AddGroupTargetAccess(groupid, target, access)
	target = string.match(target, "^[%w_]+$")
	if not target then error("Target can only have letters, digits, and underscores") end
	BSU.RegisterGroupPrivilege(groupid, BSU.PRIV_TARGET, string.lower(target), access == nil and true or access)
end

function BSU.RemoveGroupTargetAccess(groupid, target)
	target = string.match(target, "^[%w_]+$")
	if not target then error("Target can only have letters, digits, and underscores") end
	BSU.RemoveGroupPrivilege(groupid, BSU.PRIV_TARGET, string.lower(target))
end

-- returns bool if the player has access to the command
function BSU.PlayerHasCommandAccess(ply, name)
	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if not cmd then error("Command '" .. name .. "' does not exist") end

	local access = cmd:GetAccess()

	if not ply:IsValid() then return true end -- expect NULL entity means it was ran through the server console
	if access == BSU.CMD_CONSOLE then return false end

	local accessPriv = BSU.CheckPlayerPrivilege(ply:SteamID64(), BSU.PRIV_CMD, name)
	if accessPriv ~= nil then return accessPriv end
	if access == BSU.CMD_NONE then return false end

	if access == BSU.CMD_ANYONE then return true end
	if access == BSU.CMD_ADMIN and ply:IsAdmin() then return true end
	return access == BSU.CMD_SUPERADMIN and ply:IsSuperAdmin()
end

-- make a player run a command (does nothing if they do not have access to the command)
function BSU.RunCommand(ply, name, argStr, silent)
	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if not cmd then error("Command '" .. name .. "' does not exist") end

	if not BSU.PlayerHasCommandAccess(ply, name) then
		BSU.SendChatMsg(ply, BSU.CLR_ERROR, "You don't have permission to use this command")
		return
	end

	local handler = BSU.CommandHandler(ply, name, argStr, silent)

	xpcall(cmd:GetFunction(), function(err) BSU.SendChatMsg(ply, BSU.CLR_ERROR, "Command errored with: " .. string.Split(err, ": ")[2]) end, handler)
end

-- get command by name but returns nothing if it doesn't exist or is console-only
function BSU.SafeGetCommandByName(name)
	local cmd = BSU.GetCommandByName(name)
	if cmd and cmd:GetAccess() == BSU.CMD_CONSOLE then return end
	return cmd
end

-- make a player run a command but first checks if the command exists and is not console-only
function BSU.SafeRunCommand(ply, name, argStr, silent)
	if not BSU.SafeGetCommandByName(name) then BSU.SendConMsg(color_white, "Unknown BSU command: '" .. name .. "'") return end
	BSU.RunCommand(ply, name, argStr, silent)
end

net.Receive("bsu_command", function(_, ply)
	local name = net.ReadString()
	local argStr = net.ReadString()
	local silent = net.ReadBool()
	BSU.SafeRunCommand(ply, name, argStr, silent)
end)