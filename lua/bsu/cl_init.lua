-- cl_init.lua
-- initializes the client-side section

local clBaseDir = BSU.DIR_BASE .. "client/"

-- prop protection
include(clBaseDir .. "pp.lua")

-- networking
include(clBaseDir .. "networking.lua")