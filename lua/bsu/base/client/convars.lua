-- base/client/convars.lua

CreateClientConVar("bsu_permission_persist", "0", true, false, "Set if your prop protection permissions should persist or be cleared next join (1 to persist, 0 to not)", 0, 1)
CreateClientConVar("bsu_allow_fire_damage", "0", true, true, "Set if you want your props to take damage from being on fire", 0, 1)

CreateClientConVar("bsu_show_actions", "2", true, true, "Set how command messages should show; does not affect (SILENT) messages (2 for chat, 1 for console, 0 for hidden)", 0, 2)
CreateClientConVar("bsu_show_silent_actions", "2", true, true, "Set how (SILENT) command messages should show (2 for chat, 1 for console, 0 for hidden)", 0, 2)

CreateClientConVar("bsu_propinfo_enabled", "1", true, false, "Whether the BSU Prop Info HUD should be displayed or not")
CreateClientConVar("bsu_propinfo_x", "37", true, false, "BSU Prop Hud x-position")
CreateClientConVar("bsu_propinfo_y", tostring(ScrW() - 250), true, false, "BSU Prop Hud y-position")
CreateClientConVar("bsu_propinfo_w", "300", true, false, "BSU Prop Hud Width")
CreateClientConVar("bsu_propinfo_h", "100", true, false, "BSU Prop Hud Height")

CreateClientConVar("bsu_alias", "", true, false, "Set an alias for the bsu concommand")
CreateClientConVar("bsu_alias_silent", "", true, false, "Set an alias for the sbsu concommand")