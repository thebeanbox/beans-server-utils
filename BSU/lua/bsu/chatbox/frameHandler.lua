-- frameHandler.lua
-- Creates/handles showing the chatbox frames

surface.CreateFont("bsuChat", {
	font = "Arial",
	size = 16,
	weight = 700,
	antialias = false,
	extended = true
})

function bsuChat.create()
	bsuChat.frame = vgui.Create("DFrame")
	bsuChat.frame:SetSize(ScrW() * 0.325, ScrH() * 0.3)
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
		if bsuChatOpen then
			if gui.IsGameUIVisible() or input.IsKeyDown(KEY_ESCAPE) then
				gui.HideGameUI()
				bsuChat.hide()
			end
		end
	end)
	
	bsuChat.frame.OnSizeChanged = function(self, width, height)
		bsuChat.entry:SetSize(width - 10, 20)
		bsuChat.entry:SetPos(5, height - bsuChat.entry:GetTall() - 5)
		
		bsuChat.html:SetSize(width - 10, height - 60)
	end
	
	bsuChat.chatButtons = {}

	local numToggleable = 0
	for _, v in ipairs(chatTypes) do
		if v.toggleable then numToggleable = numToggleable + 1 end
	end

	for i, v in ipairs(chatTypes) do
		if not v.toggleable then continue end

		local button = vgui.Create("DButton", bsuChat.frame)
		table.insert(bsuChat.chatButtons, button)
		button:SetPos(i * 75 - 75, 0)
		button:SetSize(75, 25)
		button:SetText(string.upper(string.sub(v.type, 1, 1)) .. string.sub(v.type, 2, #v.type))
		button:SetIcon("icon16/" .. v.icon .. ".png")
		button:SetIsToggle(true)
		button:SetToggle(true)

		button.onPaint = function(self, w, h)
			draw.RoundedBoxEx(5, 0, 0, w, h, Color(255, 255, 255),
				i == 1 or not bsuChat.chatButtons[i - 1]:GetToggle(), i == numToggleable or not bsuChat.chatButtons[i + 1]:GetToggle(),
				i == 1 or not bsuChat.chatButtons[i - 1]:GetToggle(), i == numToggleable or not bsuChat.chatButtons[i + 1]:GetToggle()
			)
		end
		button.Paint = button.onPaint

		button.OnToggled = function(self, state)
			bsuChat.html:Call([[
				(() => {
					const messages = $(".messageContainer").filter(function() {
						return $(this).attr("chatType") == ]] .. i .. [[;
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
	bsuChat.entry = vgui.Create("DTextEntry", bsuChat.frame) 
	bsuChat.entry:SetSize(bsuChat.frame:GetWide() - 10, 20)
	bsuChat.entry:SetTextColor(color_white)
	bsuChat.entry:SetFont("bsuChat")
	bsuChat.entry:SetDrawBorder(false)
	bsuChat.entry:SetDrawBackground(false)
	bsuChat.entry:SetCursorColor(color_white)
	bsuChat.entry:SetHighlightColor(Color(52, 152, 219))
	bsuChat.entry:SetPos(5, bsuChat.frame:GetTall() - bsuChat.entry:GetTall() - 5)
	
	bsuChat.entry.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 225))
		derma.SkinHook("Paint", "TextEntry", self, w, h)
	end
	
	bsuChat.entry.OnTextChanged = function(self)
		if self and self.GetText then
			gamemode.Call("ChatTextChanged", self:GetText() or "")
		end
	end

	bsuChat.entry.OnKeyCodeTyped = function(self, code)
		if code == KEY_ENTER then
			local text = self:GetText()

			if #text > 0 then
				if bsuChat.chatType == "global" then
					LocalPlayer():ConCommand("say \"" .. text .. "\"")
				elseif bsuChat.chatType == "team" then
					LocalPlayer():ConCommand("say_team \"" .. text .. "\"")
				elseif bsuChat.chatType == "admin" then
					-- send admin only message
				end
			end

			bsuChat.hide()
		end
	end
	
	bsuChat.html = vgui.Create("DHTML", bsuChat.frame)
	bsuChat.html:SetSize(bsuChat.frame:GetWide() - 10, bsuChat.frame:GetTall() - 60)
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
					background-color: #252525;
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
					letter-spacing: 0.5px;
					text-shadow: 1px 1px 0 black, 1px 1px 1px black, 1px 1px 2px black, 1px 1px 3px black;
				}
				
				#chatbox {
					height: 100%;
				}
				
				.messageContainer {
					margin-bottom: 4px;
					font-family: Merriweather Sans, sans-serif;
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
					background-color: rgba(0, 0, 0, 0.7);
					height: 28px;
				}
				
				.chatIcon {
					display: inline;
					vertical-align: top;
					padding-top: 5.5px;
					padding-left: 5.5px;
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
			<div id="chatbox"></div>
		</body>
		<script>
			var isOpen = false,
			lastMessage;
			
			// message fade effect
			const runFadeAnim = () => {
				if (!isOpen) {
					window.scrollTo(0, document.body.scrollHeight);

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
			
			runFadeAnim();
		</script>
	]])
	
	bsuChat.html:AddFunction("bsuChat", "popOutFrame", function(type, msgSendTime, args)
		if bsuChat.popOut and bsuChat.popOut:IsValid() then
			if msgSendTime == bsuChat.popOut.id then
				bsuChat.popOut:Close()
				bsuChat.entry:RequestFocus()
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
		if not bsuChatOpen then
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
	bsuChatOpen = false
	
	bsuChat.html:Call([[
		(() => {
			isOpen = false;
			
			document.body.style.overflow = "hidden"; // hides scrollbar
			
			// hides message background when chat is not open
			$(".messageContainer > div").each(function() {
				$(this).css("background-color", "rgba(0, 0, 0, 0)");
			});
			
			// plays fade out anim for recent messages
			runFadeAnim();
			
			// scrolls to bottom
			window.scrollTo(0, document.body.scrollHeight);

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
	
	bsuChat.entry:SetText("")
	
	gamemode.Call("ChatTextChanged", "")
	gamemode.Call("FinishChat")
end
chat.Close = bsuChat.hide

function bsuChat.show() -- opens chatbox
	bsuChatOpen = true
	
	bsuChat.html:Call(
		[[
			(() => {
				document.body.style.overflow = "visible"; // shows scrollbar
				
				// stops fade anim for messages
				haltFadeAnim();
				
				$(".messageContainer").each(function() {
					$(this)
						.css("opacity", 1)
						.children(":first").css("background-color", "rgba(255, 255, 255, 0.25)");
				});
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

	bsuChat.entry:RequestFocus()
	
	gamemode.Call("StartChat")
end
chat.Open = bsuChat.show