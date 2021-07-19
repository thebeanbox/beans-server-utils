-- bsu_init.lua by Bonyoze
-- Makes all the shit work

DIR = "bsu/"
LIB_DIR = DIR .. "base/bsu_lib/"
SV_DIR = DIR .. "server/"
SH_DIR = DIR .. "shared/"
CL_DIR = DIR .. "client/"
MODULES_DIR = DIR .. "modules/"

local lib = file.Find(LIB_DIR .. "*.lua", "LUA") -- bsu library files
local sv = file.Find(SV_DIR .. "*.lua", "LUA") -- server files
local sh = file.Find(SH_DIR .. "*.lua", "LUA") -- shared files
local cl = file.Find(CL_DIR .. "*.lua", "LUA") -- client files

BSU = BSU or {}

-- const values
BSU.DEFAULT_RANK = 101 -- Guest team index
BSU.BOT_RANK = 108 -- Bot team index
BSU.AFK_TIMEOUT = 900 -- 900 secs (15 mins)
BSU.CMD_PREFIX = "!"

-- SERVER/CLIENT SETUP
if SERVER then
  MsgN("[BSU SERVER] Started up")
  
  -- load/send library files
  for _, file in  ipairs(lib) do
    include(LIB_DIR .. file)
    AddCSLuaFile(LIB_DIR .. file)
  end

  -- load/send base files
  include("bsu/base/database.lua") 

  include("bsu/base/teams.lua")
  AddCSLuaFile("bsu/base/teams.lua")

  include("bsu/base/player.lua")
  AddCSLuaFile("bsu/base/player.lua")

  -- load assets
  resource.AddSingleFile("materials/bsu/scoreboard/windows.png")
  resource.AddSingleFile("materials/bsu/scoreboard/mac.png")
  resource.AddSingleFile("materials/bsu/stathud/stathudIcons16.png")

  include("bsu/developer.lua") -- REMOVE THIS WHEN PUBLIC
  AddCSLuaFile("bsu/developer.lua")

  -- SERVER MODULES
  for _, file in ipairs(sv) do
    include(SV_DIR .. file)
  end

  for _, file in ipairs(sh) do
    include(SH_DIR .. file)
    AddCSLuaFile(SH_DIR .. file)
  end

  for _, file in ipairs(cl) do
    AddCSLuaFile(CL_DIR .. file)
  end

  MsgN("[BSU SERVER] Finished loading modules")
else
  MsgN("[BSU CLIENT] Started up")

  -- load library files
  for _, file in ipairs(lib) do
    include(LIB_DIR .. file)
  end

  -- load base files
  include("bsu/base/teams.lua")

  include("bsu/base/player.lua")

  include("bsu/developer.lua") -- REMOVE THIS WHEN PUBLIC

  -- CLIENT MODULES
  for _, file in ipairs(sh) do
    include(SH_DIR .. file)
  end

  for _, file in ipairs(cl) do
    include(CL_DIR .. file)
  end

  MsgN("[BSU CLIENT] Finished loading modules")
end

hook.Add("OnGamemodeLoaded", "BSU_GetTeamColorOverride", function()
  GAMEMODE.GetTeamColor = BSU.GetPlayerColor
end)