-- cl_init.lua
-- initializes the client-side section

local clBaseDir = BSU.DIR_BASE .. "client/"

-- setup shared scripts
include(BSU.DIR_BASE .. "sql.lua")
include(BSU.DIR_BASE .. "logs.lua")

-- setup client-side scripts
include(clBaseDir .. "convars.lua")
include(clBaseDir .. "pp.lua")
include(clBaseDir .. "commands.lua")
include(clBaseDir .. "vote.lua")
include(clBaseDir .. "menu/bsumenu.lua")
include(clBaseDir .. "menu/commandmenu.lua")
include(clBaseDir .. "menu/votemenu.lua")
include(clBaseDir .. "menu/groupsmenu.lua")
include(clBaseDir .. "menu/bansmenu.lua")

-- module loading
BSU.LoadModules()

hook.Run("BSU_Init")
