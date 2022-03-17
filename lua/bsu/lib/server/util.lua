-- lib/server/util.lua

-- send a console message to a player or list of players
function BSU.ConMsg(plys, ...)
  BSU.ClientRPC(plys, "BSU.ConMsg", ...)
end

-- send a chat message to a player or list of players
function BSU.ChatMsg(plys, ...)
  BSU.ClientRPC(plys, "chat.AddText", ...)
end