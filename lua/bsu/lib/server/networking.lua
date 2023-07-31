-- lib/server/networking.lua

-- add some network strings
util.AddNetworkString("bsu_client_ready") -- used to tell the server when the clientside part of the addon has loaded

util.AddNetworkString("bsu_command_run") -- used for running commands across realms

util.AddNetworkString("bsu_rpc") -- used for client RPC system
util.AddNetworkString("bsu_client_info") -- used to send client info to the server

util.AddNetworkString("bsu_perms") -- used for sending permission data to the server
util.AddNetworkString("bsu_owners") -- used for sending owner data to the clients

function BSU.ClientRPC(plys, func, ...)
	net.Start("bsu_rpc")
	net.WriteString(func)

	local args = { ... }
	local len = math.min(#args, 2 ^ 8 - 1)
	net.WriteUInt(len, 8) -- only 255 args
	for i = 1, len do
		net.WriteType(args[i])
	end

	if plys then
		net.Send(plys)
	else
		net.Broadcast()
	end
end
