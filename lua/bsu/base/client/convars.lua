-- base/client/convars.lua

CreateClientConVar("bsu_permission_persist", 0, true, false, "Whether your prop protection permissions should persist or be cleared next join (1 to persist, 0 to not)", 0, 1)
CreateClientConVar("bsu_allow_fire_damage", 0, true, true, "Whether your props should take damage from being on fire", 0, 1)

CreateClientConVar("bsu_show_actions", 2, true, true, "Set how command messages should show; does not affect (SILENT) messages (2 for chat, 1 for console, 0 for hidden)", 0, 2)
CreateClientConVar("bsu_show_silent_actions", 2, true, true, "Set how (SILENT) command messages should show (2 for chat, 1 for console, 0 for hidden)", 0, 2)

CreateClientConVar("bsu_propinfo_enabled", 1, true, false, "Whether the Prop Info HUD should be displayed", 0, 1)
CreateClientConVar("bsu_propinfo_x", 1, true, false, "", 0, 1)
CreateClientConVar("bsu_propinfo_y", 0.5, true, false, "", 0, 1)

CreateClientConVar("bsu_alias", "", true, false, "Set an alias for the bsu concommand")
CreateClientConVar("bsu_alias_silent", "", true, false, "Set an alias for the sbsu concommand")