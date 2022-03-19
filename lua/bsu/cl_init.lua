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
BSU.LoadModules()

hook.Run("BSU_Init")