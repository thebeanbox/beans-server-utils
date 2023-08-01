-- base/server/convars.lua

CreateConVar("bsu_default_group", "user", FCVAR_ARCHIVE, "The group that new players should be assigned to")
CreateConVar("bsu_bot_team", 4, FCVAR_ARCHIVE, "The team bots should be set to") -- (bots are not given their own group, instead a "Bot" team)
CreateConVar("bsu_cleanup_time", 600, FCVAR_ARCHIVE, "The time (in seconds) before disconnected players' props get cleaned up")
