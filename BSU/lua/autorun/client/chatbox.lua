-- chatbox.lua by Bonyoze
-- BSU custom chatbox

if SERVER then -- send files to client-side
	AddCSLuaFile("bsu/chatbox/frameManager.lua")
	MsgN("[BSU SERVER] Sent chatbox/frameManager.lua (client-side)")

	AddCSLuaFile("bsu/chatbox/chatManager.lua")
	MsgN("[BSU SERVER] Sent chatbox/chatManager.lua (client-side)")

	AddCSLuaFile("bsu/chatbox/messageManager.lua")
	MsgN("[BSU SERVER] Sent chatbox/messageManager.lua (client-side)")

	return
end

MsgN("[BSU CLIENT] Loaded chatbox.lua")

errorImage = "data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAMAAADz0U65AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf8A/gAAACcac5cAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAARSURBVBhXY2BgRIPkiDAyAAAEyAAhvFw1dgAAAABJRU5ErkJggg=="

bsuChat = {}
bsuChat.isOpen = false
bsuChat.chatTypes = {
	{ type = "global", icon = "world", toggleable = true }, -- VALUE 1 MUST BE GLOBAL
	{ type = "team", icon = "group", toggleable = true  }, -- VALUE 2 MUST BE TEAM
	{ type = "server", icon = "information" },
	{ type = "private", icon = "user_comment" },
	{ type = "admin", icon = "shield" },
}

-- include other files
include("bsu/chatbox/frameManager.lua")
MsgN("[BSU CLIENT] Loaded chatbox/frameManager.lua")

include("bsu/chatbox/chatManager.lua")
MsgN("[BSU CLIENT] Loaded chatbox/chatManager.lua")

include("bsu/chatbox/messageManager.lua")
MsgN("[BSU CLIENT] Loaded chatbox/messageManager.lua")

concommand.Add("bsu_chatbox_clear", function() -- clears all chat messages
	bsuChat.html:Call([[
		$("#chatbox > *").empty();
	]])
end)

hook.Add("PlayerBindPress", "BSU_OpenChatbox", function(ply, bind, pressed) -- opens the chatbox
	if bind == "messagemode" || bind == "messagemode2" then
		if IsValid(bsuChat.frame) then
			bsuChat.show()
		else
			bsuChat.create()
			bsuChat.show()
		end

		-- set the current chat mode to either global or team
		bsuChat.html:Call([[
			teamChat = ]] .. (bind == "messagemode" and "false" or "true") .. [[;
			updateInputChatIcon();
		]])

		return true
	end
end)

hook.Add("HUDShouldDraw", "BSU_HideDefaultChatbox", function(name) -- hide the default chatbox
	if name == "CHudChat" then
		return false
	end
end)

hook.Add("Initialize", "BSU_InitiateChatbox", function() -- create the chatbox panel clientside
	if not IsValid(bsuChat.frame) then
		bsuChat.create()
	end
end)