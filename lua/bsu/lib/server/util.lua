-- lib/server/util.lua

function BSU.LoadModules(dir)
  dir = dir or BSU.DIR_MODULES

  local svDir = dir .. "server/"
  local clDir = dir .. "client/"

  local shFiles, folders = file.Find(dir .. "*", "LUA")
  local svFiles = file.Find(svDir .. "*", "LUA")
  local clFiles = file.Find(clDir .. "*", "LUA")
  
  -- run server-side modules
  for _, file in ipairs(svFiles) do
    if not string.EndsWith(file, ".lua") then continue end
    include(svDir .. file)
  end

  -- run/include shared modules
  for _, file in ipairs(shFiles) do
    if not string.EndsWith(file, ".lua") then continue end
    include(dir .. file)
    AddCSLuaFile(dir .. file)
  end

  -- include client-side modules
  for _, file in ipairs(clFiles) do
    if not string.EndsWith(file, ".lua") then continue end
    AddCSLuaFile(clDir .. file)
  end

  for _, folder in ipairs(folders) do
    folder = string.lower(folder)
    if folder == "server" or folder == "client" then continue end
    BSU.LoadModules(dir .. folder .. "/")
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
  BSU.ClientRPC(plys, "BSU.SendConMsg", ...)
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