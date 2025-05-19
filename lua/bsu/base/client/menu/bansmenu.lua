local bansmenu = {}

function bansmenu:Init()
	self:Dock(FILL)

	self.bansPerPage = 50 -- 255 Max
	self.bansRemaining = 0
	self.page = 1
	self.bans = {}

	local headerPanel = vgui.Create("DPanel", self)
	headerPanel:Dock(TOP)
	headerPanel:SetHeight(25)
	self.headerPanel = headerPanel

	local previousButton = vgui.Create("DButton", headerPanel)
	previousButton:Dock(LEFT)
	previousButton:SetWidth(25)
	previousButton:SetText("")
	previousButton:SetIcon("icon16/arrow_undo.png")
	previousButton.DoClick = function()
		self:PreviousPage()
	end
	self.previousButton = previousButton

	local nextButton = vgui.Create("DButton", headerPanel)
	nextButton:Dock(LEFT)
	nextButton:SetWidth(25)
	nextButton:SetText("")
	nextButton:SetIcon("icon16/arrow_redo.png")
	nextButton.DoClick = function()
		self:NextPage()
	end
	self.nextButton = nextButton

	local refreshButton = vgui.Create("DButton", headerPanel)
	refreshButton:Dock(LEFT)
	refreshButton:SetWidth(25)
	refreshButton:SetText("")
	refreshButton:SetIcon("icon16/arrow_refresh.png")
	refreshButton.DoClick = function()
		self:LoadPage(self.page)
	end
	self.refreshButton = refreshButton

	local pageLabel = vgui.Create("DLabel", headerPanel)
	pageLabel:Dock(LEFT)
	pageLabel:SetText("Page: 1")
	pageLabel:SetTextColor(color_black)
	self.pageLabel = pageLabel

	local banList = vgui.Create("DListView", self)
	banList:Dock(FILL)
	banList:AddColumn("Player")
	banList:AddColumn("Duration")
	banList:AddColumn("Reason")
	banList:AddColumn("Admin")
	banList:AddColumn("Date")
	banList:SetHeaderHeight(25)
	banList:SetDataHeight(25)
	self.banList = banList

	self:LoadPage(1)
end

-- Requests a page of bans and updates page label
function bansmenu:LoadPage(n)
	self.page = n
	net.Start("bsu_request_banlist")
	net.WriteUInt(n, 8)
	net.WriteUInt(self.bansPerPage, 8)
	net.SendToServer()
end

-- Called after internal bans table 
function bansmenu:UpdatePage(bans)
	self.bans = bans
	self.banList:Clear()
	self.pageLabel:SetText("Page: " .. self.page)

	for _, ban in ipairs(self.bans) do
		local banName = ban.name
		local banSteamID = ban.steamid
		local banDuration = ban.duration
		local banDurationFormattedTime = (banDuration > 0) and BSU.StringTime(banDuration) or "[PERMANENT]"
		local banReason = ban.reason
		local banDate = ban.date
		local banDateFormattedTime = os.date("%c", banDate)
		local bannedByName = ban.bannedByName
		local bannedBySteamID = ban.bannedBySteamID

		local displayBanName = (banName == "N/A") and banSteamID or banName .. " <" .. banSteamID .. ">"
		local displayAdminName = (bannedByName == "[CONSOLE]") and bannedByName or bannedByName .. " <" .. bannedBySteamID .. ">"
		local newEntry = self:AddEntry(displayBanName, banDurationFormattedTime, banReason, displayAdminName, banDateFormattedTime)

		newEntry.OnRightClick = function()
			local menu = DermaMenu()

			local copySubMenu, copySubMenuOption = menu:AddSubMenu("Copy...")
			copySubMenuOption:SetIcon("icon16/page_copy.png")

			local copyName = copySubMenu:AddOption("Name", function()
				local str = banName
				SetClipboardText(str)
				notification.AddLegacy("Copied Name \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyName:SetIcon("icon16/user.png")

			local copySteamID = copySubMenu:AddOption("SteamID", function()
				local str = banSteamID
				SetClipboardText(str)
				notification.AddLegacy("Copied SteamID \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copySteamID:SetIcon("icon16/user.png")

			local copyReason = copySubMenu:AddOption("Reason", function()
				local str = banReason
				SetClipboardText(str)
				notification.AddLegacy("Copied Reason \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyReason:SetIcon("icon16/text_align_left.png")

			local copyBannedByName = copySubMenu:AddOption("Admin Name", function()
				local str = bannedByName
				SetClipboardText(str)
				notification.AddLegacy("Copied Admin Name \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyBannedByName:SetIcon("icon16/user_red.png")

			local copyBannedBySteamID = copySubMenu:AddOption("Admin SteamID", function()
				local str = bannedBySteamID
				SetClipboardText(str)
				notification.AddLegacy("Copied Admin SteamID \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyBannedBySteamID:SetIcon("icon16/user_red.png")

			local copyDate = copySubMenu:AddOption("Date", function()
				local str = banDate
				SetClipboardText(str)
				notification.AddLegacy("Copied Date \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyDate:SetIcon("icon16/calendar.png")

			menu:AddSpacer()

			local actionsSubMenu, actionsSubMenuOption = menu:AddSubMenu("Actions...")
			actionsSubMenuOption:SetIcon("icon16/shield.png")

			local unbanPlayer = actionsSubMenu:AddOption("Unban Player...", function()
				local prompt = vgui.Create("DFrame")
				prompt:SetTitle("Confirmation Prompt")
				prompt:SetSize(ScrW() * 0.15, ScrH() * 0.1)
				prompt:Center()
				prompt:MakePopup()

				local label = vgui.Create("DLabel", prompt)
				label:SetContentAlignment(5)
				label:SetText("Are you sure you would like to unban\n" .. banName .. " <" .. banSteamID .. ">?")
				label:Dock(FILL)

				local panel = vgui.Create("Panel", prompt)
				panel:Dock(BOTTOM)

				local yesButton = vgui.Create("DButton", panel)
				yesButton:SetText("YES")
				yesButton:SetWidth(prompt:GetWide() / 4)
				yesButton:Dock(LEFT)
				yesButton.DoClick = function()
					BSU.SafeRunCommand("unban", banSteamID, false)
					notification.AddLegacy("Unbanned player " .. banName .. " <" .. banSteamID .. ">", NOTIFY_CLEANUP, 2)
					prompt:Close()
				end

				local noButton = vgui.Create("DButton", panel)
				noButton:SetText("NO")
				noButton:Dock(FILL)
				noButton.DoClick = function()
					prompt:Close()
				end
			end)
			unbanPlayer:SetIcon("icon16/shield_delete.png")

			menu:Open()
		end
	end
end

function bansmenu:PreviousPage()
	if self.page - 1 < 1 then return end
	self.page = self.page - 1
	self:LoadPage(self.page)
end

function bansmenu:NextPage()
	if #self.bans < self.bansPerPage then return end
	self.page = self.page + 1
	self:LoadPage(self.page)
end

function bansmenu:AddEntry(...)
	return self.banList:AddLine(...)
end

vgui.Register("BSUBansMenu", bansmenu, "DPanel")

hook.Add("BSU_BSUMenuInit", "BSUBansMenuInit", function(bsuMenu)
	if not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()) then return end
	bansMenu = vgui.Create("BSUBansMenu", bsuMenu)
	bsuMenu:AddTab("Ban History", 4, bansMenu, "icon16/shield.png")
	BSU.BansMenu = bansMenu
end)

net.Receive("bsu_request_banlist", function()
	if not BSU.BansMenu then return end

	local bans = {}

	local banAmount = net.ReadUInt(8)
	for i = 1, banAmount do
		local ban = {
			name = net.ReadString(),
			steamid = net.ReadString(),
			reason = net.ReadString(),
			duration = net.ReadUInt(32),
			date = net.ReadUInt(32),
			bannedByName = net.ReadString(),
			bannedBySteamID = net.ReadString(),
		}
		ban.dateNiceTime = os.date("%c", ban.date)

		bans[i] = ban
	end

	BSU.BansMenu:UpdatePage(bans)
end)
