-- lib/client/util.lua

-- prints a message to console (intended to be called by client RPC)
function BSU.SendConMsg(...)
  MsgC(...)
  MsgN()
end