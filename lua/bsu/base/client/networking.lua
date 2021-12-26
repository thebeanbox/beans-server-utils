-- base/client/networking.lua

local function handleRPC()
  local funcStr = net.ReadString()
  local args = net.ReadTable()

  local func = BSU.FindVar(funcStr)
  if not func or type(func) ~= "function" then return error("Received bad RPC, invalid function (" .. funcStr .. ")!") end
  
  func(unpack(args))
end
  
net.Receive("BSU_RPC", handleRPC)