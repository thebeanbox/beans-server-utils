-- frameManager.lua by Bonyoze
-- Creates and manages showing the chatbox frames

function bsuChat.create()
	bsuChat.frame = vgui.Create("DFrame")
	bsuChat.frame:SetSize(ScrW() * 0.3, ScrH() * 0.4)
	bsuChat.frame:SetPos(ScrW() * 0.02, (ScrH() - bsuChat.frame:GetTall()) - ScrH() * 0.125)
	bsuChat.frame:SetTitle("")
	bsuChat.frame:SetScreenLock(true)
	bsuChat.frame:ShowCloseButton(false)
	bsuChat.frame:SetDraggable(true)
	bsuChat.frame:SetSizable(true)
	bsuChat.frame:SetMinWidth(bsuChat.frame:GetWide() / 2)
	bsuChat.frame:SetMinHeight(bsuChat.frame:GetTall() / 2)
	
	bsuChat.frame.Paint = function(self, w, h)
		bsuChat.blur(self, 5, 10, 50)
		draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 180))
		draw.RoundedBox(5, 0, 0, w, 25, Color(0, 0, 0, 225))
	end
	bsuChat.frame.oldPaint = bsuChat.frame.Paint;
	
	hook.Add("Think", bsuChat.frame, function(self)
		if bsuChat.isOpen then
			if gui.IsGameUIVisible() or input.IsKeyDown(KEY_ESCAPE) then
				gui.HideGameUI()
				bsuChat.hide()
			end
		end
	end)
	
	bsuChat.frame.OnSizeChanged = function(self, width, height)
		bsuChat.html:SetSize(width - 10, height - 35)
	end
	
	bsuChat.chatButtons = {}

	local buttonTypes = {}

	for type, v in pairs(bsuChat.chatTypes) do
		if v.toggleable then table.insert(buttonTypes, type) end
	end

	for type, v in pairs(bsuChat.chatTypes) do
		if not v.toggleable then continue end

		local button = vgui.Create("DButton", bsuChat.frame)
		button:SetPos(table.Count(bsuChat.chatButtons) * 75, 0)
		button:SetSize(75, 25)
		button:SetText(string.upper(string.sub(type, 1, 1)) .. string.sub(type, 2, #type))
		button:SetIcon("icon16/" .. v.icon .. ".png")
		button:SetIsToggle(true)
		button:SetToggle(true)

		bsuChat.chatButtons[type] = button

		local index = table.Count(bsuChat.chatButtons)

		button.onPaint = function(self, w, h)
			draw.RoundedBoxEx(5, 0, 0, w, h, Color(255, 255, 255),
				index == 1 or not bsuChat.chatButtons[buttonTypes[index - 1]]:GetToggle(), index == #buttonTypes or not bsuChat.chatButtons[buttonTypes[index + 1]]:GetToggle(),
				index == 1 or not bsuChat.chatButtons[buttonTypes[index - 1]]:GetToggle(), index == #buttonTypes or not bsuChat.chatButtons[buttonTypes[index + 1]]:GetToggle()
			)
		end
		button.Paint = button.onPaint

		button.OnToggled = function(self, state)
			bsuChat.html:Call([[
				(() => {
					const messages = $("#chatbox > .messageContainer").filter(function() {
						return $(this).attr("chatType") == "]] .. type .. [[";
					});

					if (messages.length) {
						if (]] .. (state and "true" or "false") .. [[) {
							messages.show();
						} else {
							messages.hide();
						}
					}
				})();
			]])

			if state then
				self:SetTextColor(Color(0, 0, 0))
				self:SetIcon("icon16/" .. v.icon .. ".png")
				self.Paint = self.onPaint
			else
				self:SetTextColor(Color(255, 255, 255))
				self:SetIcon("icon16/cancel.png")
				self.Paint = function() end
			end
		end
	end
	
	bsuChat.html = vgui.Create("DHTML", bsuChat.frame)
	bsuChat.html:SetSize(bsuChat.frame:GetWide() - 10, bsuChat.frame:GetTall() - 35)
	bsuChat.html:SetPos(5, 30)

	--bsuChat.html.ConsoleMessage = function() end -- prevents html print messages from appearing in the client's console

	bsuChat.html:SetHTML([[
		<head>
			<httpProtocol>  
				<customHeaders>
					<add name="Access-Control-Allow-Origin" value="*"/>
				</customHeaders>
			</httpProtocol>
			<link href="https://fonts.googleapis.com/css2?family=Merriweather+Sans:wght@400&display=swap" rel="stylesheet">
			<style>
				::selection {
					color: white;
					background: #3199DC;
				}
			
				::-webkit-scrollbar {
					width: 6px;
				}
				::-webkit-scrollbar-track {
					background-color: rgba(0, 0, 0, 0.75);
					border-radius: 10px;
				}
				::-webkit-scrollbar-thumb {
					border-radius: 10px;
					border: 2px solid #F5F5F5;
					background-color: white;
				}

				* {
					user-select: none;
				}
				
				body {
					position: absolute;
					width: 100%;
					height: 100%;
					margin: 0;
					padding: 0;
					overflow: hidden;
					letter-spacing: 0.5px;
					text-align: left;
					text-shadow: 1px 1px 0 black, 1px 1px 1px black, 1px 1px 2px black, 1px 1px 3px black;
					font-family: Merriweather Sans, sans-serif;
				}

				hr {
					border: 3px solid rgba(0, 0, 0, 0.75);
					border-radius: 3px;
				}

				#chatboxContainer {
					display: block;
					overflow-y: auto;
					width: 100vw;
					height: 100%;
				}
				#chatboxContainer > div {
					
				}

				#inputboxContainer > div {
					border-radius: 5px;
					background-color: rgba(255, 255, 255, 0.25);
					width: 100vw;
				}

				#inputChatIcon {
					display: inline-block;
					vertical-align: top;
					border-radius: 5px;
					background-color: rgba(0, 0, 0, 0.75);
					height: 28px;
				}
				#inputChatIcon > img {
					display: inline;
					vertical-align: top;
					padding: 6px;
					width: 16px;
					height: 16px;
				}

				#inputText {
					display: inline;
					padding-right: 6px;
				}
				#inputText > input {
					display: table-cell;
					width: calc(100vw - 38px);
					height: 28px;
					background-color: rgba(0, 0, 0, 0);
					border: 0px solid transparent;
					outline: 0px solid transparent;
					font-size: 14px;
					letter-spacing: 0.5px;
					text-shadow: 1px 1px 0 black, 1px 1px 1px black, 1px 1px 2px black, 1px 1px 3px black;
					font-family: Merriweather Sans, sans-serif;
					line-height: 28px;
					color: white;
				}
				
				.messageContainer {
					left: 0;
					margin-bottom: 4px;
				}
				.messageContainer > div {
					display: inline-block;
					padding-left: 6px;
					padding-right: 6px;
					border-radius: 5px;
					min-height: 28px;
				}
				
				.messageHeader {
					display: inline-block;
					vertical-align: top;
					margin-left: -6px;
					margin-right: 4px;
					border-radius: 5px;
					background-color: rgba(0, 0, 0, 0.75);
					height: 28px;
				}
				
				.chatIcon {
					display: inline;
					vertical-align: top;
					padding: 6px 0 6px 6px;
					width: 16px;
					height: 16px;
				}

				.timestamp {
					display: inline;
					vertical-align: middle;
					padding-left: 4px;
					padding-right: 4px;
					color: white;
					font-size: 10px;
					line-height: 28px;
				}
				
				.avatar {
					display: inline;
					vertical-align: top;
					width: 28px;
					height: 28px;
					border-radius: 4px;
				}

				.name {
					user-select: text;
					vertical-align: text-middle;
					padding-left: 4px;
					padding-right: 4px;
					font-size: 14px;
					font-weight: 900;
					line-height: 28px;
				}

				.messageText, .messageText > span {
					display: inline;
					user-select: text;
					vertical-align: text-middle;
					font-size: 14px;
					line-height: 28px;
					overflow-wrap: anywhere;
				}
				
				.hyperlink {
					color: rgb(25, 125, 225);
					text-decoration: none;
					cursor: pointer;
				}
				.hyperlink:hover {
					text-decoration: underline;
				}
				
				.messageImage {
					display: block;
					margin-top: 6px;
					margin-bottom: 6px;
					border-radius: 5px;
					border-style: none;
					position: relative;
					overflow: hidden;
					line-height: 0;
				}
				.messageImage > img {
					margin: 0;
					border-radius: 5px;
					border-style: none;
					max-width: 100%;
					min-height: 32px;
					max-height: 160px;
					cursor: pointer;
				}
				.spoiler {
					transform: scale(1.15);
					filter: blur(10px);
				}
			</style>
			<script src="asset://garrysmod/html/js/thirdparty/jquery.js"></script>
		</head>
		<body>
			<table cellspacing=0 cellpadding=0 style="position: absolute; bottom: 0; left: 0; width: inherit; height: inherit;">
				<tr>
					<td>
						<div id="chatboxContainer">
							<div id="chatbox"></div>
						</div>
					</td>
				</tr>
				<tr style="height: 0;">
					<td>
						<div id="inputboxContainer">
							<hr>
							<div>
								<div id="inputChatIcon">
									<img></img>
								</div>
								<div id="inputText">
									<input type="text" maxlength=126 spellcheck="false"></input>
								</div>
							</div>
						</div>
					</td>
				</tr>
			</table>
		</body>
		<script>
			var isOpen = false,
			teamChat = false;
			
			const updateInputChatIcon = () => {
				$("#inputChatIcon > img").attr("src", "asset://garrysmod/materials/icon16/" + ((!teamChat) ? "]]
					.. bsuChat.chatTypes["global"].icon
					.. [[" : "]]
					.. bsuChat.chatTypes["team"].icon
					.. [[") + ".png");
			}
			
			const scrollToBottom = check => {
				const el = $("#chatboxContainer");
				if (check) {
					if (el.scrollTop() + el.height() + 32 < el[0].scrollHeight) return;
				}
				el[0].scrollTo(0, el[0].scrollHeight);
			}

			// message fade effect
			const runFadeAnim = () => {
				if (!isOpen) {
					scrollToBottom();

					const currTime = Date.now();
					
					$(".messageContainer").each(function() {
						if ($(this).css("opacity") != 0 && currTime - $(this).data("sendTime") >= 14000) {
							$(this).css("opacity", Math.min(1 - (currTime - $(this).data("sendTime") - 14000) / 1000, 1));
						}
					});
					
					setTimeout(runFadeAnim, 50); // repeat anim every 50 ms
				}
			}
			
			const haltFadeAnim = () => {
				isOpen = true;
			}

			// add input key detecting
			$("#inputText > input")
				.keydown(function(e) {
					if (e.key === "Tab") {
						teamChat = !teamChat;
						updateInputChatIcon();
						
						e.preventDefault();
					} else if (e.key === "Enter") {
						bsuChat.sayText(teamChat, $(this).val());
						$(this).val("");
					}
				});

			
			// set input chat type icon
			updateInputChatIcon();
			
			// run fade anim on start
			if (!isOpen) runFadeAnim();
		</script>
	]])
	
	bsuChat.html:AddFunction("bsuChat", "sayText", function(teamChat, text)
		if not teamChat then
			LocalPlayer():ConCommand("say \"" .. text .. "\"")
		else
			LocalPlayer():ConCommand("say_team \"" .. text .. "\"")
		end

		bsuChat.hide()
	end)

	bsuChat.html:AddFunction("bsuChat", "popOutFrame", function(type, msgSendTime, args)
		if bsuChat.popOut and bsuChat.popOut:IsValid() then
			if msgSendTime == bsuChat.popOut.id then
				bsuChat.popOut:Close()
				bsuChat.focusInputBox()
				return
			else
				bsuChat.popOut:Close()
			end
		end

		bsuChat.popOut = vgui.Create("DFrame")
		bsuChat.popOut.id = msgSendTime
		bsuChat.popOut:SetSize(args.width + 10, args.height + 34)
		bsuChat.popOut:SetTitle(args.src)
		bsuChat.popOut:SetScreenLock(true)
		bsuChat.popOut:ShowCloseButton(true)
		bsuChat.popOut:SetDraggable(true)
		bsuChat.popOut:SetSizable(true)
		bsuChat.popOut:MakePopup()
		bsuChat.popOut:SetPos(ScrW() / 2 - bsuChat.popOut:GetWide() / 2, ScrH() / 2 - bsuChat.popOut:GetTall() / 2)
		bsuChat.popOut.btnMaxim:SetVisible(false)
		bsuChat.popOut.btnMinim:SetVisible(false)

		bsuChat.popOut.Paint = function(self, w, h)
			bsuChat.blur(self, 5, 10, 50)
			draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 180))
			draw.RoundedBox(5, 0, 0, w, 25, Color(0, 0, 0, 225))
		end
		bsuChat.popOut.oldPaint = bsuChat.popOut.Paint

		bsuChat.popOut.OnClose = function()
			bsuChat.focusInputBox()
		end

		bsuChat.popOut.html = vgui.Create("DHTML", bsuChat.popOut)
		bsuChat.popOut.html:Dock(FILL)

		bsuChat.popOut.html.ConsoleMessage = function() end -- prevents html print messages from appearing in the client's console

		if type == "hyperlink" then
			bsuChat.popOut:SetMinWidth(250)
			bsuChat.popOut:SetMinHeight(175)
			bsuChat.popOut.html:OpenURL(args.src)
		elseif type == "image" then
			bsuChat.popOut:SetMinWidth(args.width + 10)
			bsuChat.popOut:SetMinHeight(args.height + 34)
			bsuChat.popOut.html:SetHTML([[
				<body style="margin: 0;">
					<img style="width: 100%; height: 100%;" src="]] .. args.src .. [["></img>
				</body>
			]])
		end
	end)

	hook.Add("Think", bsuChat.html, function(self)
		if not bsuChat.isOpen then
			if gui.IsGameUIVisible() then
				if self:IsVisible() then
					self:SetVisible(false)
				end
			else
				self:SetVisible(true)
			end
		elseif not self:IsVisible() then
			self:SetVisible(true)
		end
	end)
	
	--bsuChat.html:SetAllowLua(true)
	
	bsuChat.hide()
end

local blur = Material("pp/blurscreen")
function bsuChat.blur(panel, layers, density, alpha)
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (i / layers) * density)
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
	end
end

function bsuChat.hide() -- closes chatbox
	bsuChat.isOpen = false
	
	bsuChat.html:Call([[
		(() => {
			isOpen = false;
			
			$("#chatboxContainer").css("overflow-y", "hidden"); // hides scrollbar
			
			// hides message background when chat is not open
			$(".messageContainer > div").each(function() {
				$(this).css("background-color", "rgba(0, 0, 0, 0)");
			});
			
			// hide input box
			$("#inputboxContainer").css("visibility", "hidden");

			// plays fade out anim for recent messages
			runFadeAnim();
			
			// scrolls to bottom
			scrollToBottom();

			// unselects anything
			document.getSelection().removeAllRanges();
		})();
	]])
	
	-- hide/disable chatbox frame
	bsuChat.frame.Paint = function() end

	local children = bsuChat.frame:GetChildren()
	for _, pnl in pairs(children) do
		if pnl == bsuChat.html or pnl == bsuChat.frame.btnMaxim or pnl == bsuChat.frame.btnClose or pnl == bsuChat.frame.btnMinim then continue end
		pnl:SetVisible(false)
	end

	bsuChat.frame:SetMouseInputEnabled(false)
	bsuChat.frame:SetKeyboardInputEnabled(false)

	-- hide/disable popout frame
	if bsuChat.popOut and bsuChat.popOut:IsValid() then
		bsuChat.popOut.Paint = function() end

		local popOutChildren = bsuChat.popOut:GetChildren()
		for _, pnl in pairs(popOutChildren) do
			if pnl == bsuChat.popOut.html or pnl == bsuChat.popOut.btnMaxim or pnl == bsuChat.popOut.btnMinim then continue end
			pnl:SetVisible(false)
		end

		bsuChat.popOut:SetMouseInputEnabled(false)
		bsuChat.popOut:SetKeyboardInputEnabled(false)
	end

	gui.EnableScreenClicker(false)
	
	-- clear input box
	bsuChat.html:Call([[
		$("#inputText > input").val("");
	]])
	
	gamemode.Call("ChatTextChanged", "")
	gamemode.Call("FinishChat")
end
chat.Close = bsuChat.hide

function bsuChat.show() -- opens chatbox
	bsuChat.isOpen = true
	
	bsuChat.html:Call(
		[[
			(() => {
				$("#chatboxContainer").css("overflow-y", "auto"); // shows scrollbar
				
				scrollToBottom();

				// stops fade anim for messages
				haltFadeAnim();
				
				// show 
				$(".messageContainer").each(function() {
					$(this)
						.css("opacity", 1)
						.children(":first").css("background-color", "rgba(255, 255, 255, 0.25)");
				});

				// show input box
				$("#inputboxContainer").css("visibility", "visible");
			})();
		]]
	)
	
	-- show/enable chatbox frame
	bsuChat.frame.Paint = bsuChat.frame.oldPaint;

	local children = bsuChat.frame:GetChildren()
	for _, pnl in pairs(children) do
		if pnl == bsuChat.frame.btnMaxim or pnl == bsuChat.frame.btnClose or pnl == bsuChat.frame.btnMinim then continue end
		pnl:SetVisible(true)
	end

	bsuChat.frame:MakePopup()

	-- show/enable popout frame
	if bsuChat.popOut and bsuChat.popOut:IsValid() then
		bsuChat.popOut.Paint = bsuChat.popOut.oldPaint

		local popOutChildren = bsuChat.popOut:GetChildren()
		for _, pnl in pairs(popOutChildren) do
			if pnl == bsuChat.popOut.html or pnl == bsuChat.popOut.btnMaxim or pnl == bsuChat.popOut.btnMinim then continue end
			pnl:SetVisible(true)
		end

		bsuChat.popOut:MakePopup()
	end

	bsuChat.focusInputBox()
	
	gamemode.Call("StartChat")
end
chat.Open = bsuChat.show

function bsuChat.focusInputBox()
	bsuChat.html:RequestFocus()
	bsuChat.html:Call([[
		$("#inputText > input").focus();
	]])
end