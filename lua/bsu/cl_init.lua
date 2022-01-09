-- cl_init.lua
-- initializes the client-side section

local clBaseDir = BSU.DIR_BASE .. "client/"

-- setup shared scripts
include(BSU.DIR_BASE .. "sql.lua")

-- setup client-side scripts
include(clBaseDir .. "sql.lua")
include(clBaseDir .. "networking.lua")
include(clBaseDir .. "pp.lua")

-- module loading
local clModulesDir = BSU.DIR_MODULES .. "client/"

local shModules = file.Find(BSU.DIR_MODULES .. "*.lua", "LUA")
local clModules = file.Find(clModulesDir .. "*.lua", "LUA")

-- run shared modules
for _, module in ipairs(shModules) do
  include(BSU.DIR_MODULES .. module)
end

-- run client-side modules
for _, module in ipairs(clModules) do
  include(clModulesDir .. module)
end
