-- chatManager.lua by Bonyoze
-- Manages chat sending and messages appearing on the chatbox

function bsuChat.send(data) -- adds a message to the chatbox
	if not IsValid(bsuChat.frame) then return end
		
	if not data.avatar and data.sender and data.sender:IsPlayer() then
		data.avatar = loadPlyAvatarIcon(data.sender, data)
		return
	end

	local visible = true
	if data.chatType and bsuChat.chatButtons[data.chatType] then
		visible = bsuChat.chatButtons[data.chatType]:GetToggle()
	end
	
	bsuChat.html:Call(
	[[
		(() => {
			const messageVisible = ]] .. (visible and "true" or "false") .. [[,
			chatType = ]] .. (data.chatType and ('"' .. data.chatType .. '"') or "null") .. [[,
			chatIcon = ]] .. ((data.chatType and bsuChat.chatTypes[data.chatType]) and ('"' .. bsuChat.chatTypes[data.chatType].icon .. '"') or "null") .. [[,
			timestamp = ]] .. ((data.showTimestamp == nil || data.showTimestamp) and "true" or "false") .. [[,
			avatar = ]] .. (data.avatar and ('"' .. string.JavascriptSafe(data.avatar) .. '"') or "null") .. [[,
			name = ]] .. (data.name and ('"' .. string.JavascriptSafe(data.name) .. '"') or "null") .. [[,
			nameColor = ]] .. (data.nameColor and ('"rgb(' .. data.nameColor.r .. ", " .. data.nameColor.g .. ", " .. data.nameColor.b .. ')"') or '"rgb(151, 211, 255)"') .. [[;
			
			const sendTime = new Date();

			const messageContainer = $("<div>")
				.addClass("messageContainer")
				.data("sendTime", sendTime.getTime())
				.appendTo($("#chatbox"));

			if (!messageVisible) messageContainer.hide();
			if (chatType) messageContainer.attr("chatType", chatType);

			const messageContainerChild = $("<div>")
				.appendTo(messageContainer);
			if (isOpen) messageContainerChild.css("background-color", "rgba(255, 255, 255, 0.25)");
			
			if (timestamp || name) {
				const messageHeader = $("<div>")
					.addClass("messageHeader")
					.appendTo(messageContainerChild);

				if (chatIcon) {
					$("<img>")
						.addClass("chatIcon")
						.attr("src", "asset://garrysmod/materials/icon16/" + chatIcon + ".png")
						.appendTo(messageHeader);
				}

				if (timestamp) {
					$("<span>")
						.addClass("timestamp")
						.append(
							document.createTextNode(
								sendTime.toLocaleTimeString(navigator.language, {
									hour: "numeric",
									minute: "2-digit",
									hour12: true
								})
							)
						)
						.appendTo(messageHeader);
				}
				
				if (avatar) {
					$("<img>")
						.addClass("avatar")
						.attr("src", avatar)
						.appendTo(messageHeader);
				}

				if (name) {
					$("<span>")
						.addClass("name")
						.append(document.createTextNode(name))
						.css("color", nameColor)
						.appendTo(messageHeader);
				}
			}

			$("<p>")
				.addClass("messageText")
				.appendTo(messageContainerChild);

			scrollToBottom(true);
		})();
	]])
	
	local hasText = false
	local textSegs = {}

	for k, msg in ipairs(data.messageContent) do
		if msg.type == "text" or msg.type == "hyperlink" then
			hasText = true
			table.insert(textSegs, msg)
		end
	end

	if hasText then
		if textSegs[1].type != "hyperlink" then textSegs[1].value = string.TrimLeft(textSegs[1].value) end
		if textSegs[#textSegs].type != "hyperlink" then textSegs[#textSegs].value = string.TrimRight(textSegs[#textSegs].value) end
	end

	function buildMessageHTML()
		local color, italic, bold, strikethrough = Color(151, 211, 255), false, false, false
		
		for _, msg in ipairs(data.messageContent) do
			local type = msg.type
			local value = msg.value
	
			if type == "text" then
				bsuChat.html:Call([[
					$("<span>")
						.append(document.createTextNode("]] .. string.JavascriptSafe(value) .. [["))
						.css(
							{
								"color": "rgb(]] .. color.r .. ", " .. color.g .. ", " .. color.b .. [[)",
								"font-style": "]] .. (italic and "italic" or "normal") .. [[",
								"font-weight": "]] .. (bold and "900" or "normal") .. [[",
								"text-decoration": "]] .. (strikethrough and "line-through" or "none") .. [["
							}
						)
						.appendTo($("#chatbox > .messageContainer").last().find(".messageText")[0]);
				]]);
			elseif type == "hyperlink" then
				bsuChat.html:Call([[
					$("<span>")
						.addClass("hyperlink")
						.append(document.createTextNode("]] .. string.JavascriptSafe(value.text or value.url) .. [["))
						.css(
							{
								"font-style": "]] .. (italic and "italic" or "normal") .. [[",
								"font-weight": "]] .. (bold and "bold" or "normal") .. [["
							}
						)
						.click(function() {
							bsuChat.popOutFrame(
								"hyperlink",
								$(this).parent().parent().parent()[0].sendTime,
								{
									src: "]] .. string.JavascriptSafe(value.url) .. [[",
									width: 1000,
									height: 700
								}
							);
						})
						.appendTo($("#chatbox > .messageContainer").last().find("div").find(".messageText")[0]);
				]]);
			elseif type == "image" then
				bsuChat.html:Call([[
					$("<img>")
						.attr("src", "]] .. string.JavascriptSafe(value) .. [[")
						.click(function() {
							bsuChat.popOutFrame(
								"image",
								$(this).parent().parent().parent()[0].sendTime,
								{
									src: this.src, width: this.width,
									height: this.height
								}
							);
						})
						.error(function() {
							$(this)
								.off("load")
								.attr("src", "]] .. string.JavascriptSafe(errorImage) .. [[")
								.css(
									{
										"image-rendering": "pixelated",
										"cursor": "default"
									}
								)
						}).appendTo(
							$("<div>")
								.addClass("messageImage")
								.appendTo($("#chatbox > .messageContainer").last().find("div")[0])
						);
				]]);
			elseif type == "color" then
				color = value
			elseif type == "italic" then
				italic = value
			elseif type == "bold" then
				bold = value
			elseif type == "strikethrough" then
				strikethrough = value
			end
		end
	
		if not hasText then -- remove right margin if there is no text
			bsuChat.html:Call([[
				$(".messageContainer").last().find(".messageHeader").css("margin-right", "-6px");
			]])
		end
	end

	buildMessageHTML()

	bsuChat.html:SetVisible(true)
end

function chat.AddText(...) -- other messages
	bsuChat.send(
		{
			messageContent = formatMsg(...),
			showTimestamp = false
		}
	)
end

hook.Add("OnPlayerChat", "BSU_SendPlayerMsg", function(player, text, teamChat, isDead) -- messages from players
	if not teamChat or (teamChat and LocalPlayer():Team() == player:Team()) then
		local name, nameColor = (player and player:IsValid()) and player:Nick() or "Console", (player and player:IsValid()) and team.GetColor(player:Team()) or Color(151, 211, 255)
		local messageContent = formatPlyMsg(text)

		table.insert(messageContent,
			1,
			{
				type = "color",
				value = color_white
			}
		)

		bsuChat.send(
			{
				chatType = not teamChat and "global" or "team",
				messageContent = messageContent,
				sender = player,
				name = name,
				nameColor = nameColor
			}
		)

		MsgC(nameColor, name, color_white, ": ", text, "\n")
	end

	return true
end)

hook.Add("ChatText", "BSU_SendServerMsg", function(index, name, text, chatType) -- messages from the server
	if chatType == "servermsg" then
		bsuChat.send(
			{
				chatType = "server", -- server
				messageContent = formatMsg(Color(0, 160, 255), text),
			}
		)

		MsgC(col, text, "\n")
	elseif chatType == "none" then
		bsuChat.send(
			{
				messageContent = formatMsg(text),
				showTimestamp = false
			}
		)

		MsgC(text, "\n")
	end

	return true
end)

net.Receive("BSU_PlayerJoinLeaveMsg", function() -- custom player join/leave message
	local name, nameColor, joinLeave = net.ReadString(), net.ReadTable(), net.ReadBool()
	
	bsuChat.send(
		{
			chatType = joinLeave and "connect" or "disconnect",
			messageContent = {
				{ -- set name color
					type = "color",
					value = nameColor
				},
				{ -- make upcoming name bold
					type = "bold",
					value = true
				},
				{ -- player name
					type = "text",
					value = name
				},
				{ -- no longer bold
					type = "bold",
					value = false
				},
				{ -- reset color
					type = "color",
					value = color_white
				},
				{ -- joined or left text
					type = "text",
					value = joinLeave and " has joined the server" or " has left the server"
				}
			}
		}
	)

	MsgC(nameColor, name, color_white, joinLeave and " has joined the server" or " has left the server", "\n")
end)

gameevent.Listen("player_changename")
hook.Add("player_changename", "BSU_PlayerNameChangeMsg", function(data) -- custom player name change message
	local player = Player(data.userid)
	local nameColor = team.GetColor(Player(data.userid):Team())
	
	bsuChat.send(
		{
			chatType = "namechange",
			messageContent = {
				{ -- set name color
					type = "color",
					value = nameColor
				},
				{ -- make upcoming name bold
					type = "bold",
					value = true
				},
				{ -- old name
					type = "text",
					value = data.oldname
				},
				{ -- no longer bold
					type = "bold",
					value = false
				},
				{ -- reset color
					type = "color",
					value = color_white
				},
				{
					type = "text",
					value = " changed their name to "
				},
				{ -- set name color again
					type = "color",
					value = nameColor
				},
				{ -- make upcoming name bold
					type = "bold",
					value = true
				},
				{ -- new name
					type = "text",
					value = data.newname
				},
			}
		}
	)

	MsgC(nameColor, data.oldname, color_white, " changed their name to ", nameColor, data.newname, "\n")
end)