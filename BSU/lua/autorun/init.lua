DIR = "bsu/"
SV_DIR = DIR .. "server/"
SH_DIR = DIR .. "shared/"
CL_DIR = DIR .. "client/"

-- SETUP IMPORTANT FILES
MsgN("[BSU] INITIALIZING...")

include(SV_DIR .. "database.lua") -- setup the db
include(SV_DIR .. "teams.lua") -- load team data from db
include(SV_DIR .. "players.lua") -- assign player data from db to players and manage rank perms
include(SV_DIR .. "anti_skybox.lua") -- skybox prop spawn protection

MsgN("[BSU] FINISHED MAIN SETUP")

-- SETUP CHATBOX

for _, file in ipairs(file.Find(DIR .. "chatbox/*.lua", "LUA")) do
	AddCSLuaFile(DIR .. "chatbox/" .. file)
end

-- LOAD OTHER FILES
MsgN("[BSU] LOADING FILES:")

local shFiles = file.Find(SH_DIR .. "*.lua", "LUA") -- shared files
local clFiles = file.Find(CL_DIR .. "*.lua", "LUA") -- client files

local fileNum = 0

for _, file in ipairs(shFiles) do -- including shared files and sending to clientside
	fileNum = fileNum + 1
	
	include(SH_DIR .. file)
	AddCSLuaFile(SH_DIR .. file)
	
	MsgN(" " .. fileNum .. ". shared/" .. file)
end

for _, file in ipairs(clFiles) do -- sending client files to clientside
	fileNum = fileNum + 1
	
	AddCSLuaFile(CL_DIR .. file)
	
	MsgN(" " .. fileNum .. ". client/" .. file)
end

MsgN("[BSU] FINISHED LOADING " .. (#shFiles + #clFiles) .. " FILES")

-- INIT CLIENT SIDE
AddCSLuaFile("autorun/cl_init.lua")
