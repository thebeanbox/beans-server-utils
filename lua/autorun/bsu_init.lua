--[[
    ____ _____ __  __
   / __ ) ___// / / /
  / __  \__ \/ / / /
 / /_/ /__/ / /_/ /
/_____/____/\____/

A utilities and moderation addon for a dedicated Garry's Mod server
--]]

BSU = BSU or {}

BSU.DIR = "bsu/"
BSU.DIR_BASE = BSU.DIR .. "base/"
BSU.DIR_LIB = BSU.DIR .. "lib/"
BSU.DIR_MODULES = BSU.DIR .. "modules/"

include(BSU.DIR .. "defines.lua")
AddCSLuaFile(BSU.DIR .. "defines.lua")

local shLib = file.Find(BSU.DIR_LIB .. "*.lua", "LUA")
local clLib = file.Find(BSU.DIR_LIB .. "client/*.lua", "LUA")

for _, v in ipairs(shLib) do
	include(BSU.DIR_LIB .. v)
	AddCSLuaFile(BSU.DIR_LIB .. v)
end

if SERVER then
	local svLib = file.Find(BSU.DIR_LIB .. "server/*.lua", "LUA")

	for _, v in ipairs(svLib) do
		include(BSU.DIR_LIB .. "server/" .. v)
	end

	for _, v in ipairs(clLib) do
		AddCSLuaFile(BSU.DIR_LIB .. "client/" .. v)
	end

	include(BSU.DIR .. "init.lua")
	AddCSLuaFile(BSU.DIR .. "init.lua")

	return
end

for _, v in ipairs(clLib) do
	include(BSU.DIR_LIB .. "client/" .. v)
end

include(BSU.DIR .. "init.lua")
