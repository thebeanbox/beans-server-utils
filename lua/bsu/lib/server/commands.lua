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
	if not target then error("Target can only have letters, digits, or underscores") end
	BSU.RegisterGroupPrivilege(groupid, BSU.PRIV_TARGET, string.lower(target), access == nil and true or access)
end

function BSU.RemoveGroupTargetAccess(groupid, target)
	target = string.match(target, "^[%w_]+$")
	if not target then error("Target can only have letters, digits, or underscores") end
	BSU.RemoveGroupPrivilege(groupid, BSU.PRIV_TARGET, string.lower(target))
end

-- returns bool if the player has access to the command
function BSU.PlayerHasCommandAccess(ply, name)
	if not ply:IsValid() then return true end -- a NULL entity means it was ran through the server console so we don't need to check

	name = string.lower(name)
	local cmd = BSU._cmds[name]
	if not cmd then error("Command '" .. name .. "' does not exist") end

	if ply:IsSuperAdmin() then return true end
	local accessPriv = BSU.CheckPlayerPrivilege(ply:SteamID64(), BSU.PRIV_CMD, name)
	if accessPriv ~= nil then return accessPriv end
	if cmd.access == BSU.CMD_NOONE then return false end
	if cmd.access == BSU.CMD_ANYONE then return true end
	return cmd.access == BSU.CMD_ADMIN and ply:IsAdmin()
end

-- make a player run a command (does nothing if they do not have access to the command)
function BSU.RunCommand(name, ply, argStr, silent)
	if not BSU.PlayerHasCommandAccess(ply, name) then
		return BSU.SendChatMsg(ply, BSU.CLR_ERROR, "You don't have permission to use this command")
	end

	local cmd = BSU._cmds[name]
	if not cmd then error("Command '" .. name .. "' does not exist") end

	local handler = BSU.CommandHandler(ply, argStr, silent)

	xpcall(cmd.func, function(err) BSU.SendChatMsg(ply, BSU.CLR_ERROR, "Command errored with: " .. string.Split(err, ": ")[2]) end, handler, ply, table.Copy(handler._args), argStr)
end