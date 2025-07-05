-- base/client/networking.lua

local function ReceiveRPC()
	local path = net.ReadString()

	local func = BSU.FindVar(path)
	if not func or type(func) ~= "function" then return error("Received bad RPC, invalid function (" .. path .. ")") end

	local lcalls = net.ReadUInt(12)
	for _ = 1, lcalls do
		local args = {}
		local largs = net.ReadUInt(5)
		for i = 1, largs do
			args[i] = net.ReadType()
		end
		ProtectedCall(func, unpack(args, 1, largs))
	end
end

net.Receive("bsu_rpc", ReceiveRPC)
