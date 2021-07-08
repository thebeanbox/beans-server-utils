-- bsu_init.lua by Bonyoze
-- Makes all the shit work

DIR = "bsu/"
SV_DIR = DIR .. "server/"
SH_DIR = DIR .. "shared/"
CL_DIR = DIR .. "client/"

local sv = file.Find(SV_DIR .. "*.lua", "LUA") -- server files
local sh = file.Find(SH_DIR .. "*.lua", "LUA") -- shared files
local cl = file.Find(CL_DIR .. "*.lua", "LUA") -- client files

BSU = BSU or {}

-- const values
BSU.DEFAULT_RANK = 101 -- Guest team index
BSU.BOT_RANK = 107 -- Bot team index

-- SERVER/CLIENT SETUP
if SERVER then
  MsgN("[BSU SERVER] Started up")

  -- load/send base scripts
  include("bsu/base/database.lua") 

  include("bsu/base/teams.lua")
  AddCSLuaFile("bsu/base/teams.lua")

  include("bsu/base/player.lua")

  include("bsu/developer.lua")
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

  include("bsu/base/teams.lua")

  include("bsu/developer.lua")

  -- CLIENT MODULES
  for _, file in ipairs(sh) do
    include(SH_DIR .. file)
  end

  for _, file in ipairs(cl) do
    include(CL_DIR .. file)
  end

  MsgN("[BSU CLIENT] Finished loading modules")
end