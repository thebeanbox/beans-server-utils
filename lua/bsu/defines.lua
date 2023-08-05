-- bsu/defines.lua
-- defines some values on both the server and client

-- privilege types
BSU.PRIV_MODEL  = 0
BSU.PRIV_NPC    = 1
BSU.PRIV_SENT   = 2
BSU.PRIV_SWEP   = 3
BSU.PRIV_TOOL   = 4
BSU.PRIV_CMD    = 5
BSU.PRIV_TARGET = 6
BSU.PRIV_MISC	= 7

-- prop protection enums
BSU.PP_PHYSGUN = 1
BSU.PP_GRAVGUN = 2
BSU.PP_TOOLGUN = 4
BSU.PP_USE     = 8
BSU.PP_DAMAGE  = 16

-- color values (mainly used for command messages)
BSU.CLR_ERROR    = Color(255, 127, 0)   -- error messages                        (orange)
BSU.CLR_TEXT     = Color(150, 210, 255) -- normal text                           (light blue)
BSU.CLR_PARAM    = Color(0, 255, 0)     -- when a parameter isn't an entity      (green)
BSU.CLR_SELF     = Color(75, 0, 130)    -- when target is client                 (dark purple)
BSU.CLR_EVERYONE = Color(0, 130, 130)   -- when targeting all plys on the server (cyan)
BSU.CLR_CONSOLE  = Color(0, 0, 0)       -- server console name                   (black)
BSU.CLR_MISC     = Color(255, 255, 255) -- other (just used for non-player ents) (white)

BSU.CMD_PREFIX = "!"
BSU.CMD_PREFIX_SILENT = "/"

if SERVER then
	-- server SQL database table names
	BSU.SQL_TEAMS         = "bsu_teams"
	BSU.SQL_GROUPS        = "bsu_groups"
	BSU.SQL_PLAYERS       = "bsu_players"
	BSU.SQL_PDATA         = "bsu_pdata"
	BSU.SQL_BANS          = "bsu_bans"
	BSU.SQL_GROUP_PRIVS   = "bsu_grp_privs"
	BSU.SQL_PLAYER_PRIVS  = "bsu_ply_privs"
	BSU.SQL_GROUP_LIMITS  = "bsu_grp_limits"
	BSU.SQL_PLAYER_LIMITS = "bsu_ply_limits"

	-- command access values
	BSU.CMD_CONSOLE    = 0 -- access only via the server console (command is also not networked to client)
	BSU.CMD_NONE       = 1 -- access only via the server console and privileges
	BSU.CMD_ADMIN      = 2 -- access only for admins, superadmins and via the server console
	BSU.CMD_SUPERADMIN = 3 -- access only for superadmins and via the server console
	BSU.CMD_ANYONE     = 4 -- access to all

	BSU.BAN_MSG = [[============ You've Been Banned! ===========

Ban Reason:
%reason%

Time Length:
%duration%

Time Remaining:
%remaining%

Ban Date:
%time%

=====================================]]
else
	-- client SQL database table names
	BSU.SQL_PP = "bsu_pp"
end