-- bsu/defines.lua
-- defines some values on both the server and client

BSU = BSU or {}

-- some info
BSU.TITLE = "Beans Server Utilities"
BSU.VERSION = "0.0.1-dev"

-- directory paths
BSU.DIR = "bsu/"
BSU.DIR_BASE = BSU.DIR .. "base/"
BSU.DIR_LIB = BSU.DIR .. "lib/"
BSU.DIR_MODULES = BSU.DIR .. "modules/"

if SERVER then
  -- SQL database table names
  BSU.SQL_GROUPS        = "bsu_groups"
  BSU.SQL_PLAYERS       = "bsu_players"
  BSU.SQL_BANS          = "bsu_bans"
  BSU.SQL_GROUP_PRIVS   = "bsu_grp_privs"
  BSU.SQL_PLAYER_PRIVS  = "bsu_ply_privs"
  BSU.SQL_GROUP_LIMITS  = "bsu_grp_limits"
  BSU.SQL_PLAYER_LIMITS = "bsu_ply_limits"
  BSU.SQL_PP_GRANTS     = "bsu_pp_grants"

  -- SQL privilege consts
  BSU.PRIV_MODEL = 0
  BSU.PRIV_NPC   = 1
  BSU.PRIV_SENT  = 2
  BSU.PRIV_SWEP  = 3
  BSU.PRIV_TOOL  = 4

  -- prop protection values
  BSU.PP_PHYSGUN = 0
  BSU.PP_GRAVGUN = 1
  BSU.PP_TOOLGUN = 2
  BSU.PP_USE     = 3
  BSU.PP_DAMAGE  = 4

  -- id of the group that players are automatically set to (like when they join for the first time)
  BSU.DEFAULT_GROUP = 1

  -- id of the group that bots should be assigned to
  BSU.BOT_GROUP = 2 --BSU.DEFAULT_GROUP

  BSU.BAN_MSG = [[============ You've Been Banned! ===========

[ Ban Reason ]:
%reason%

[ Time Length ]:
%duration%

[ Time Remaining ]:
%remaining%

[ Ban Date ]:
%time%

=====================================]]
end