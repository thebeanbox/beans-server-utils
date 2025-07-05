-- lib/server/networking.lua

-- add some network strings
util.AddNetworkString("bsu_command_run") -- used for running commands across realms

util.AddNetworkString("bsu_rpc") -- used for client RPC system
util.AddNetworkString("bsu_client_info") -- used to send client info to the server

util.AddNetworkString("bsu_perms") -- used for sending permission data to the server

-- used for sending prop protection data
util.AddNetworkString("bsu_init_owners")
util.AddNetworkString("bsu_owner_info")
util.AddNetworkString("bsu_set_owner")
util.AddNetworkString("bsu_clear_owner")

local rpc

function BSU.StartRPC(path)
	rpc = { path = path, calls = {} }
end

function BSU.AddArgsRPC(...)
	assert(rpc, "RPC not started")
	local calls = rpc.calls
	calls[#calls + 1] = { ... }
end

function BSU.FinishRPC(plys)
	assert(rpc, "RPC not started")
	local path, calls = rpc.path, rpc.calls
	rpc = nil

	if #calls <= 0 then return end

	net.Start("bsu_rpc")
	net.WriteString(path)

	local lcalls = #calls
	lcalls = math.min(lcalls, 2 ^ 12 - 1)
	net.WriteUInt(lcalls, 12) -- 4095 calls max

	for i = 1, lcalls do
		local args = calls[i]

		-- can't use # operator because nil can be present, so get highest index
		local largs = 0
		for idx in pairs(args) do
			largs = math.max(largs, idx)
		end

		largs = math.min(largs, 2 ^ 5 - 1)
		net.WriteUInt(largs, 5) -- 31 args max

		for ii = 1, largs do
			net.WriteType(args[ii])
		end
	end

	if plys then
		net.Send(plys)
	else
		net.Broadcast()
	end
end

function BSU.ClientRPC(plys, path, ...)
	BSU.StartRPC(path)
	BSU.AddArgsRPC(...)
	BSU.FinishRPC(plys)
end
