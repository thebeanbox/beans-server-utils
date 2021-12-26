-- bsu/defines.lua
-- defines some values on both the server and client

BSU = BSU or {}

-- some info
BSU.TITLE = "Beans Server Utilities"
BSU.VERSION = "0.0.1"

-- directory paths
BSU.DIR = "bsu/"
BSU.DIR_BASE = BSU.DIR .. "base/"
BSU.DIR_LIB = BSU.DIR .. "lib/"
BSU.DIR_MODULES = BSU.DIR .. "modules/"

if SERVER then
  -- SQL database table names (bad idea to modify these if there's already existing tables with data)
  BSU.SQL_GROUPS            = "bsu_groups"
  BSU.SQL_PLAYERS           = "bsu_players"
  BSU.SQL_BANS              = "bsu_bans"
  BSU.SQL_GROUP_PRIVILEGES  = "bsu_grp_privileges"
  BSU.SQL_PLAYER_PRIVILEGES = "bsu_ply_privileges"
  BSU.SQL_GROUP_LIMITS      = "bsu_grp_limits"
  BSU.SQL_PLAYER_LIMITS     = "bsu_ply_limits"

  -- SQL privilege consts
  BSU.PRIVILEGE_MODEL = 0
  BSU.PRIVILEGE_NPC   = 1
  BSU.PRIVILEGE_SENT  = 2
  BSU.PRIVILEGE_SWEP  = 3
  BSU.PRIVILEGE_TOOL  = 4

  -- id of the group that players are automatically set to (like when they join for the first time)
  BSU.DEFAULT_GROUP = 1

  -- id of the group that bots should be assigned to
  BSU.BOT_GROUP = 2 --BSU.DEFAULT_GROUP

  BSU.BAN_MSG = [[============ You've Been Banned! ===========

[Ban Date]:
%time%

[ Reason ]:
%reason%

[ Length ]:
%duration%

[ Remaining ]:
%remaining%

=====================================]]
end