--[[
    ____ _____ __  __
   / __ ) ___// / / /
  / __  \__ \/ / / /
 / /_/ /__/ / /_/ /
/_____/____/\____/

A utilities and moderation addon for a dedicated Garry's Mod server
--]]

if BSU then return end

include("bsu/defines.lua")
if SERVER then AddCSLuaFile(BSU.DIR .. "defines.lua") end

local shLib = file.Find(BSU.DIR_LIB .. "*.lua", "LUA")
local clLib = file.Find(BSU.DIR_LIB .. "client/*.lua", "LUA")

-- load/send shared library
for _, v in ipairs(shLib) do
	include(BSU.DIR_LIB .. v)
	if SERVER then AddCSLuaFile(BSU.DIR_LIB .. v) end
end

if SERVER then
	local svLib = file.Find(BSU.DIR_LIB .. "server/*.lua", "LUA")

	-- load server library
	for _, v in ipairs(svLib) do
		include(BSU.DIR_LIB .. "server/" .. v)
	end

	-- send client library
	for _, v in ipairs(clLib) do
		AddCSLuaFile(BSU.DIR_LIB .. "client/" .. v)
	end

	-- initialize server-side
	include(BSU.DIR .. "sv_init.lua")
	AddCSLuaFile(BSU.DIR .. "cl_init.lua")
else
	-- load client library
	for _, v in ipairs(clLib) do
		include(BSU.DIR_LIB .. "client/" .. v)
	end

	-- initialize client-side
	include(BSU.DIR .. "cl_init.lua")
end