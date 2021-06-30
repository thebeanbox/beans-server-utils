DIR = "bsu/"
SH_DIR = DIR .. "shared/"
CL_DIR = DIR .. "client/"

include(SH_DIR .. "chatbox.lua")

--[[-- LOADING FILES
MsgN("[BSU] LOADING FILES:")

local shFiles = file.Find(SH_DIR .. "*.lua", "LUA") -- shared files
local clFiles = file.Find(CL_DIR .. "*.lua", "LUA") -- client files

local fileNum = 0

for _, file in ipairs(shFiles) do -- including shared files
	fileNum = fileNum + 1
	
	include(SH_DIR .. file)
	
	MsgN(" " .. fileNum .. ". shared/" .. file)
end

for _, file in ipairs(clFiles) do -- including client files
	fileNum = fileNum + 1
	
	include(CL_DIR .. file)
	
	MsgN(" " .. fileNum .. ". client/" .. file)
end

MsgN("[BSU] FINISHED LOADING " .. (#shFiles + #clFiles) .. " FILES")]]