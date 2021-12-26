-- lib/server/networking.lua

-- add some network strings
util.AddNetworkString("BSU_RPC") -- used for client RPC system
util.AddNetworkString("BSU_ClientInfo") -- used to send client info to the server

function BSU.ClientRPC(plys, func, ...)
  net.Start("BSU_RPC")
  net.WriteString(func)
  net.WriteTable({ ... })

  if plys then
    net.Send(plys)
  else
    net.Broadcast()
  end
end