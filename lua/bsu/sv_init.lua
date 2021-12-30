-- sv_init.lua
-- initializes the server-side section

local svBaseDir = BSU.DIR_BASE .. "server/"
local clBaseDir = BSU.DIR_BASE .. "client/"

-- setup server-side scripts

include(svBaseDir .. "sql.lua")
include(svBaseDir .. "groups.lua")
include(svBaseDir .. "players.lua")
include(svBaseDir .. "privileges.lua")
include(svBaseDir .. "limits.lua")
include(svBaseDir .. "bans.lua")
include(svBaseDir .. "pp.lua")

-- send client-side scripts

-- prop protection
AddCSLuaFile(clBaseDir .. "pp.lua")

-- networking
AddCSLuaFile(clBaseDir .. "networking.lua")


-- Module loading
local svModulesDir = BSU.DIR_MODULES .. "server/"
local clModulesDir = BSU.DIR_MODULES .. "client/"

local shModules = file.Find(BSU.DIR_MODULES .. "*.lua", "LUA")
local svModules = file.Find(svModulesDir .. "*.lua", "LUA")
local clModules = file.Find(clModulesDir .. "*.lua", "LUA")

-- Run server-side modules
for _, module in ipairs(svModules) do
  include(svModulesDir .. module)
end

-- Run shared modules
for _, module in ipairs(shModules) do
  include(BSU.DIR_MODULES .. module)
  AddCSLuaFile(BSU.DIR_MODULES .. module)
end

-- Include client-side modules
for _, module in ipairs(clModules) do
  AddCSLuaFile(clModulesDir .. module)
end