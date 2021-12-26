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

-- send client-side scripts

-- networking
AddCSLuaFile(clBaseDir .. "networking.lua")

--[[
local svModulesDir = BSU.DIR_MODULES .. "server/"
local clModulesDir = BSU.DIR_MODULES .. "client/"

local shModules = file.Find(BSU.DIR_MODULES .. "*.lua", "LUA")
local svModules = file.Find(svModulesDir .. "*.lua", "LUA")
local clModules = file.Find(clModulesDir .. "*.lua", "LUA")

-- run module scripts


]]