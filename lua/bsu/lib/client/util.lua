-- lib/client/util.lua

function BSU.LoadModules(dir)
  dir = dir or BSU.DIR_MODULES

  local clDir = dir .. "client/"

  local shFiles, folders = file.Find(dir .. "*.lua", "LUA")
  local clFiles = file.Find(clDir .. "*.lua", "LUA")

  -- run shared modules
  for _, module in ipairs(shFiles) do
    include(dir .. module)
  end

  -- run client-side modules
  for _, module in ipairs(clFiles) do
    include(clDir .. module)
  end

  -- load sub directories
  for _, folder in ipairs(folders) do
    folder = string.lower(folder)
    if folder ~= "server" and folder ~= "client" then
      BSU.LoadModule(dir .. folder .. "/")
    end
  end
end

-- prints a message to console (intended to be called by client RPC)
function BSU.SendConMsg(...)
  MsgC(...)
  MsgN()
end