-- chatbox.lua by Bonyoze
-- BSU custom chatbox

if SERVER then
	-- send files to client-side
	AddCSLuaFile("bsu/modules/chatbox/frameManager.lua")
	AddCSLuaFile("bsu/modules/chatbox/chatManager.lua")
	AddCSLuaFile("bsu/modules/chatbox/messageManager.lua")

	-- setup hooks for player join/leave custom messages
	util.AddNetworkString("BSU_PlayerJoinLeaveMsg")

	hook.Add("PlayerInitialSpawn", "BSU_PlayerConnectMsg", function(ply)
		net.Start("BSU_PlayerJoinLeaveMsg")
			net.WriteString(ply:Nick())
			net.WriteTable(BSU:GetPlayerData(ply) and team.GetColor(BSU:GetPlayerData(ply)) or team.GetColor(ply:Team()))
			net.WriteBool(true)
			net.WriteBool(BSU:GetPlayerData(ply) == nil) -- is first time joining
			net.WriteBool(ply:IsBot()) -- player is a bot
		net.Send(player.GetAll())
	end)
	hook.Add("PlayerDisconnected", "BSU_PlayerDisconnectMsg", function(ply)
		net.Start("BSU_PlayerJoinLeaveMsg")
			net.WriteString(ply:Nick())
			net.WriteTable(BSU:GetPlayerData(ply) and team.GetColor(BSU:GetPlayerData(ply)) or team.GetColor(ply:Team()))
			net.WriteBool(false)
			-- these must be added but aren't used
			net.WriteBool(false)
			net.WriteBool(ply:IsBot())
		net.Send(player.GetAll())
	end)

	return
end

errorImage = "data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAMAAADz0U65AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf8A/gAAACcac5cAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAARSURBVBhXY2BgRIPkiDAyAAAEyAAhvFw1dgAAAABJRU5ErkJggg=="

bsuChat = bsuChat or {}
bsuChat.isOpen = false
bsuChat.chatType = "global"
bsuChat.chatTypes = {
	-- Main types (DO NOT REMOVE)
	global     = { icon = "world", toggleable = true },
	team       = { icon = "group", toggleable = true  },
	admin      = { icon = "shield"--[[, toggleable = user is admin]] },
	private    = { icon = "user_comment" },
	-- Other types (cosmetic)
	server     = { icon = "information" }, -- misc server msgs
	connect    = { icon = "connect" }, -- player joined server
	disconnect = { icon = "disconnect" }, -- player left server
	namechange = { icon = "user_edit" } -- player changed name
}

-- include other files
include("bsu/modules/chatbox/frameManager.lua")
include("bsu/modules/chatbox/chatManager.lua")
include("bsu/modules/chatbox/messageManager.lua")

concommand.Add("bsu_chatbox_clear", function() -- clears all chat messages
	bsuChat.html:Call([[
		$("#chatbox > *").empty();
	]])
end)

hook.Add("PlayerBindPress", "BSU_OpenChatbox", function(ply, bind, pressed) -- opens the chatbox
	if bind == "messagemode" || bind == "messagemode2" then
		-- set current chatType
		if bind == "messagemode" then
			bsuChat.chatType = "global"
		elseif bind == "messagemode2" then
			bsuChat.chatType = "team"
		end

		-- show the chatbox
		if IsValid(bsuChat.frame) then
			bsuChat.show()
		else
			bsuChat.create()
			bsuChat.show()
		end

		-- update chat icon
		bsuChat.chatIcon:SetImage("icon16/" .. bsuChat.chatTypes[bsuChat.chatType].icon .. ".png")

		return true
	end
end)

hook.Add("HUDShouldDraw", "BSU_HideDefaultChatbox", function(name) -- hide the default chatbox
	if name == "CHudChat" then
		return false
	end
end)

hook.Add("InitPostEntity", "BSU_ChatboxInit", function()
	if not IsValid(bsuChat.frame) then
		bsuChat.create()
	end
end)