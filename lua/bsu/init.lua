-- initialize the base

local function LoadBaseSH(name)
	include(BSU.DIR_BASE .. name .. ".lua")
	if SERVER then AddCSLuaFile(BSU.DIR_BASE .. name .. ".lua") end
end

local function LoadBaseSV(name)
	if SERVER then include(BSU.DIR_BASE .. "server/" .. name .. ".lua") end
end

local function LoadBaseCL(name)
	if CLIENT then include(BSU.DIR_BASE .. "client/" .. name .. ".lua") end
	if SERVER then AddCSLuaFile(BSU.DIR_BASE .. "client/" .. name .. ".lua") end
end

LoadBaseSH("sql")
LoadBaseSH("logs")

LoadBaseSV("convars")
LoadBaseSV("sql")
LoadBaseSV("teams")
LoadBaseSV("groups")
LoadBaseSV("players")
LoadBaseSV("bans")
LoadBaseSV("privileges")
LoadBaseSV("limits")
LoadBaseSV("pp")
LoadBaseSV("commands")
LoadBaseSV("vote")
-- menu
LoadBaseSV("menu/bsumenu")
LoadBaseSV("menu/bansmenu")
LoadBaseSV("menu/groupsmenu")

LoadBaseCL("convars")
LoadBaseCL("networking")
LoadBaseCL("pp")
LoadBaseCL("commands")
LoadBaseCL("vote")
-- menu
LoadBaseCL("menu/bsumenu")
LoadBaseCL("menu/commandmenu")
LoadBaseCL("menu/votemenu")
LoadBaseCL("menu/groupsmenu")
LoadBaseCL("menu/bansmenu")
-- vgui
LoadBaseCL("vgui/propinfo")

BSU.LoadModules()

hook.Run("BSU_Init")
