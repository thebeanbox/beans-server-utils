-- lib/server/util.lua

-- send a console message to a player or list of players
-- or set target to NULL to send in the server console
function BSU.SendConMsg(plys, ...)
  if plys == NULL then
    MsgC(...)
    MsgN()
    return
  end
  BSU.ClientRPC(plys, "BSU.ConMsg", ...)
end

-- send a chat message to a player or list of players
-- or set target to NULL to send in the server console
function BSU.SendChatMsg(plys, ...)
  if plys == NULL then
    MsgC(...)
    MsgN()
    return
  end
  BSU.ClientRPC(plys, "chat.AddText", ...)
end