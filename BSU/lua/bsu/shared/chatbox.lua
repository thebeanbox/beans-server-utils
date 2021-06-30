-- chatbox.lua
-- BSU custom chatbox

if SERVER then
	
	return
end

errorImage = "data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAMAAADz0U65AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf8A/gAAACcac5cAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAARSURBVBhXY2BgRIPkiDAyAAAEyAAhvFw1dgAAAABJRU5ErkJggg=="

bsuChat = {}
bsuChatOpen = false

chatTypes = {
	{ type = "global", icon = "world", toggleable = true },
	{ type = "team", icon = "group", toggleable = true  },
	{ type = "server", icon = "information" },
	{ type = "private", icon = "user_comment" },
	{ type = "admin", icon = "shield" },
}

include(DIR .. "chatbox/frameHandler.lua")
include(DIR .. "chatbox/chatHandler.lua")
include(DIR .. "chatbox/messageHandler.lua")

concommand.Add("bsuChat_clear", function() -- clears all chat messages
	bsuChat.html:Call([[
		$("#chatbox > *").empty();
	]])
end)

hook.Add("PlayerBindPress", "", function(ply, bind, pressed) -- open the chatbox
	if bind == "messagemode" || bind == "messagemode2" then
		if bind == "messagemode" then
			bsuChat.chatType = "global"
		else
			bsuChat.chatType = "team"
		end
		
		if IsValid(bsuChat.frame) then
			bsuChat.show()
		else
			bsuChat.create()
			bsuChat.show()
		end

		return true
	end
end)

hook.Add("HUDShouldDraw", "", function(name) -- hide the default chatbox
	if name == "CHudChat" then
		return false
	end
end)

hook.Add("Initialize", "", function() -- create the chatbox panel clientside
	if not IsValid(bsuChat.frame) then
		bsuChat.create()
	end
end)