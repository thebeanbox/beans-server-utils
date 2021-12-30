-- base/client/networking.lua

local function handleRPC()
  local funcStr = net.ReadString()

  local len = net.ReadInt(16)
  local args = {}
  for i = 1, len do
    local arg = net.ReadType()
    table.insert(args, arg)
  end

  local func = BSU.FindVar(funcStr)
  if not func or type(func) ~= "function" then return error("Received bad RPC, invalid function (" .. funcStr .. ")!") end
  
  func(unpack(args))
end
  
net.Receive("BSU_RPC", handleRPC)