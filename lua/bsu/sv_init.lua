-- sv_init.lua
-- initializes the server-side section

local svBaseDir = BSU.DIR_BASE .. "server/"
local clBaseDir = BSU.DIR_BASE .. "client/"

-- setup/send shared scripts
include(BSU.DIR_BASE .. "sql.lua")
AddCSLuaFile(BSU.DIR_BASE .. "sql.lua")

-- setup server-side scripts
include(svBaseDir .. "sql.lua")
include(svBaseDir .. "groups.lua")
include(svBaseDir .. "players.lua")
include(svBaseDir .. "privileges.lua")
include(svBaseDir .. "limits.lua")
include(svBaseDir .. "bans.lua")
include(svBaseDir .. "pp.lua")

-- setup/send shared scripts
include(BSU.DIR_BASE .. "sql.lua")
AddCSLuaFile(BSU.DIR_BASE .. "sql.lua")

-- send client-side scripts
AddCSLuaFile(clBaseDir .. "sql.lua")
AddCSLuaFile(clBaseDir .. "networking.lua")
AddCSLuaFile(clBaseDir .. "pp.lua")

-- module loading
BSU.LoadModules()

hook.Run("BSU_Init")