-- base/client/networking.lua

local function handleRPC()
	local str = net.ReadString()

	local func = BSU.FindVar(str)
	if not func or type(func) ~= "function" then return error("Received bad RPC, invalid function (" .. str .. ")") end

	local lcalls = net.ReadUInt(12)
	for _ = 1, lcalls do
		local args = {}
		local largs = net.ReadUInt(4)
		for i = 1, largs do
			args[i] = net.ReadType()
		end
		xpcall(func, ErrorNoHaltWithStack, unpack(args, 1, largs))
	end
end

net.Receive("bsu_rpc", handleRPC)
