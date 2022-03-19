-- lib/server/util.lua

function BSU.LoadModules(dir)
  dir = dir or BSU.DIR_MODULES
  print(dir)

  local svDir = dir .. "server/"
  local clDir = dir .. "client/"

  local shFiles = file.Find(dir .. "*.lua", "LUA")
  local svFiles = file.Find(svDir .. "*.lua", "LUA")
  local clFiles = file.Find(clDir .. "*.lua", "LUA")

  -- run server-side modules
  for _, module in ipairs(svFiles) do
    include(svDir .. module)
  end

  -- run/include shared modules
  for _, module in ipairs(shFiles) do
    include(dir .. module)
    AddCSLuaFile(dir .. module)
  end

  -- include client-side modules
  for _, module in ipairs(clFiles) do
    AddCSLuaFile(clDir .. module)
  end

  -- load sub directories
  local _, folders = file.Find(dir .. "*", "LUA")

  for _, folder in ipairs(folders) do
    folder = string.lower(folder)
    if folder ~= "server" and folder ~= "client" then
      BSU.LoadModules(dir .. folder .. "/")
    end
  end
end

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