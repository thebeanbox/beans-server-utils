-- lib/server/networking.lua

-- add some network strings
util.AddNetworkString("BSU_RPC") -- used for client RPC system
util.AddNetworkString("BSU_ClientInfo") -- used to send client info to the server

function BSU.ClientRPC(plys, func, ...)
  net.Start("BSU_RPC")
  net.WriteString(func)

  local tableToWrite = {...}
  net.WriteInt(#tableToWrite, 16) -- Only 32766 args :)
  for k, v in pairs(tableToWrite) do
    net.WriteType(v) -- Still not the best but the args can be any value so there's no other option
  end

  if plys then
    net.Send(plys)
  else
    net.Broadcast()
  end
end