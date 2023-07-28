-- lib/server/networking.lua

-- add some network strings
util.AddNetworkString("bsu_client_ready") -- used to tell the server when the clientside part of the addon has loaded

util.AddNetworkString("bsu_command_run") -- used for running commands across realms

util.AddNetworkString("bsu_rpc") -- used for client RPC system
util.AddNetworkString("bsu_client_info") -- used to send client info to the server

util.AddNetworkString("bsu_pp_data") -- used for sending prop protection data across realms

function BSU.ClientRPC(plys, func, ...)
	net.Start("bsu_rpc")
	net.WriteString(func)

	local tableToWrite = {...}
	net.WriteInt(#tableToWrite, 16) -- Only 32766 args :)
	for _, v in pairs(tableToWrite) do
		net.WriteType(v) -- Still not the best but the args can be any value so there's no other option
	end

	if plys then
		net.Send(plys)
	else
		net.Broadcast()
	end
end
