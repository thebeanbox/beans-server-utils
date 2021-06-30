-- chatHandler.lua
-- Handles chat sending and messages appearing on the chatbox

function bsuChat.send(data) -- adds a message to the chatbox
	if not IsValid(bsuChat.frame) then
		bsuChat.create()
	end
		
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
			chatType = ]] .. (data.chatType or "null") .. [[,
			chatIcon = ]] .. ((data.chatType and chatTypes[data.chatType]) and ('"' .. chatTypes[data.chatType].icon .. '"') or "null") .. [[,
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

			window.scrollTo(0, document.body.scrollHeight);
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
						.appendTo($(".messageContainer").last().find(".messageText")[0]);
				]]);
			elseif type == "hyperlink" then
				bsuChat.html:Call([[
					$("<span>")
						.addClass("hyperlink")
						.append(document.createTextNode("]] .. string.JavascriptSafe(value.text or value.url) .. [["))
						.css(
							{
								"font-style": "]] .. (italic and "italic" or "normal") .. [[",
								"font-weight": "]] .. (bold and "900" or "normal") .. [["
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
						.appendTo($(".messageContainer").last().find("div").find(".messageText")[0]);
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
								.appendTo($(".messageContainer").last().find("div")[0])
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
				$(".messageHeader").last().css("margin-right", "-6px");
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

hook.Add("OnPlayerChat", "", function(player, text, teamChat, isDead) -- messages from players
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
				chatType = not teamChat and 1 or 2, -- global or team
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

hook.Add("ChatText", "", function(index, name, text, chatType) -- messages from the server
	if chatType != "chat" then
		local col = Color(151, 211, 255) -- default color
		
		if chatType == "joinleave" || chatType == "servermsg" then -- game msgs
			col = Color(0, 160, 255)
		elseif chatType == "namechange" || chatType == "teamchange" then -- player info msgs
			col = Color(255, 123, 0)
		end
		
		
		bsuChat.send(
			{
				chatType = 3, -- server
				messageContent = formatMsg(col, text),
				showTimestamp = chatType != "none"
			}
		)

		MsgC(col, text, "\n")
	end

	return true
end)