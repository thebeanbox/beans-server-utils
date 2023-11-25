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
	banList:AddColumn("Name")
	banList:AddColumn("SteamID")
	banList:AddColumn("Duration")
	banList:AddColumn("Reason")
	banList:AddColumn("Banned By")
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
function bansmenu:UpdatePage()
	self.banList:Clear()
	self.pageLabel:SetText("Page: " .. self.page)
	for _, ban in ipairs(self.bans) do
		local newEntry = self:AddEntry(ban.name, ban.steamid, ban.duration, ban.reason, ban.bannedByName, ban.dateNiceTime)
		newEntry.banDate = ban.date
		newEntry.bannedBySteamID = ban.bannedBySteamID

		newEntry.OnRightClick = function(s)
			local menu = DermaMenu()

			local copyName = menu:AddOption("Copy Name", function()
				local str = s:GetColumnText(1)
				SetClipboardText(str)
				notification.AddLegacy("Copied Name \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyName:SetIcon("icon16/page_copy.png")

			local copySteamID = menu:AddOption("Copy SteamID", function()
				local str = s:GetColumnText(2)
				SetClipboardText(str)
				notification.AddLegacy("Copied SteamID \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copySteamID:SetIcon("icon16/page_copy.png")

			local copyReason = menu:AddOption("Copy Reason", function()
				local str = s:GetColumnText(3)
				SetClipboardText(str)
				notification.AddLegacy("Copied Reason \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyReason:SetIcon("icon16/page_copy.png")

			local copyBannedByName = menu:AddOption("Copy Admin Name", function()
				local str = s:GetColumnText(4)
				SetClipboardText(str)
				notification.AddLegacy("Copied Admin Name \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyBannedByName:SetIcon("icon16/page_copy.png")

			local copyBannedBySteamID = menu:AddOption("Copy Admin SteamID", function()
				local str = s.bannedBySteamID
				SetClipboardText(str)
				notification.AddLegacy("Copied Admin SteamID \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyBannedBySteamID:SetIcon("icon16/page_copy.png")

			local copyDate = menu:AddOption("Copy Date", function()
				local str = s.banDate
				SetClipboardText(str)
				notification.AddLegacy("Copied Date \"" .. str .. "\"", NOTIFY_CLEANUP, 2)
			end)
			copyDate:SetIcon("icon16/page_copy.png")

			menu:AddSpacer()

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
	if self.bansRemaining < 1 then return end
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
		ban.dateNiceTime = os.date("%c", ban.time)

		bans[i] = ban
	end

	BSU.BansMenu.bans = bans
	BSU.BansMenu:UpdatePage()
end)

