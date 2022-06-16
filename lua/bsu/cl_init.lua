-- cl_init.lua
-- initializes the client-side section

local clBaseDir = BSU.DIR_BASE .. "client/"

-- setup shared scripts
include(BSU.DIR_BASE .. "sql.lua")

-- setup client-side scripts
include(clBaseDir .. "sql.lua")
include(clBaseDir .. "networking.lua")
include(clBaseDir .. "pp.lua")
include(clBaseDir .. "commands.lua")

-- module loading
BSU.LoadModules()

-- tell server the client is ready
hook.Add("InitPostEntity", "BSU_ClientReady", function()
  net.Start("bsu_client_ready")
  net.SendToServer()
end)

hook.Run("BSU_Init")