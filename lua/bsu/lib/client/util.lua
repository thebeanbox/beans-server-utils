-- lib/client/util.lua

function BSU.LoadModules(dir)
  dir = dir or BSU.DIR_MODULES

  local clDir = dir .. "client/"

  local shFiles, folders = file.Find(dir .. "*", "LUA")
  local clFiles = file.Find(clDir .. "*", "LUA")

  -- run shared modules
  for _, file in ipairs(shFiles) do
    if not string.EndsWith(file, ".lua") then continue end
    include(dir .. file)
  end

  -- run client-side modules
  for _, file in ipairs(clFiles) do
    if not string.EndsWith(file, ".lua") then continue end
    include(clDir .. file)
  end

  for _, folder in ipairs(folders) do
    folder = string.lower(folder)
    if folder == "client" then continue end
    BSU.LoadModules(dir .. folder .. "/")
  end
end

-- prints a message to console (intended to be called by client RPC)
function BSU.SendConMsg(...)
  MsgC(...)
  MsgN()
end