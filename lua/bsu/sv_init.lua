-- sv_init.lua
-- initializes the server-side section

local svBaseDir = BSU.DIR_BASE .. "server/"
local clBaseDir = BSU.DIR_BASE .. "client/"

-- setup/send shared scripts
include(BSU.DIR_BASE .. "sql.lua")
AddCSLuaFile(BSU.DIR_BASE .. "sql.lua")

-- setup server-side scripts
include(svBaseDir .. "convars.lua")
include(svBaseDir .. "sql.lua")
include(svBaseDir .. "teams.lua")
include(svBaseDir .. "groups.lua")
include(svBaseDir .. "players.lua")
include(svBaseDir .. "pdata.lua")
include(svBaseDir .. "bans.lua")
include(svBaseDir .. "privileges.lua")
include(svBaseDir .. "limits.lua")
include(svBaseDir .. "pp.lua")
include(svBaseDir .. "commands.lua")
-- voting
include(svBaseDir .. "vote.lua")
-- server-side menu
include(svBaseDir .. "menu/bsumenu.lua")
include(svBaseDir .. "menu/bansmenu.lua")

-- send client-side scripts
AddCSLuaFile(clBaseDir .. "convars.lua")
AddCSLuaFile(clBaseDir .. "networking.lua")
AddCSLuaFile(clBaseDir .. "pp.lua")
AddCSLuaFile(clBaseDir .. "commands.lua")
-- voting
AddCSLuaFile(clBaseDir .. "vote.lua")
-- client-side menu
AddCSLuaFile(clBaseDir .. "menu/bsumenu.lua")
AddCSLuaFile(clBaseDir .. "menu/commandmenu.lua")
AddCSLuaFile(clBaseDir .. "menu/votemenu.lua")
AddCSLuaFile(clBaseDir .. "menu/groupsmenu.lua")
AddCSLuaFile(clBaseDir .. "menu/bansmenu.lua")

-- module loading
BSU.LoadModules()

net.Receive("bsu_client_ready", function(_, ply)
	hook.Run("BSU_ClientReady", ply)
end)

hook.Run("BSU_Init")
