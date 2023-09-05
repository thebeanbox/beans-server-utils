local bansMenu = {}

function bansMenu:Init()
	self:Dock(FILL)

	self.currentPage = 1
	self.bans = {}

	topPanel = vgui.Create("DPanel", self)
	topPanel:Dock(TOP)
	topPanel:SetHeight(25)
	self.topPanel = topPanel

	local previousButton = vgui.Create("DButton", topPanel)
	previousButton:SetIcon("icon16/arrow_undo.png")
	previousButton:SetText("")
	previousButton:Dock(LEFT)
	previousButton:SetWidth(25)
	previousButton.DoClick = function()
		self:PreviousPage()
	end
	self.previousButton = previousButton

	local nextButton = vgui.Create("DButton", topPanel)
	nextButton:SetIcon("icon16/arrow_redo.png")
	nextButton:SetText("")
	nextButton:Dock(LEFT)
	nextButton:SetWidth(25)
	nextButton.DoClick = function()
		self:NextPage()
	end
	self.nextButton = nextButton

	local currentPageLabel = vgui.Create("DLabel", topPanel)
	currentPageLabel:SetText("Page: 1")
	currentPageLabel:SetTextColor(Color(0, 0, 0))
	currentPageLabel:Dock(LEFT)
	self.currentPageLabel = currentPageLabel

	listPanel = vgui.Create("DPanel", self)
	listPanel:Dock(FILL)
	self.listPanel = listPanel

	local banList = vgui.Create("DListView", listPanel)
	banList:Dock(FILL)
	banList:AddColumn("Name")
	banList:AddColumn("SteamID")
	banList:AddColumn("Duration")
	banList:AddColumn("Reason")
	banList:AddColumn("Date")
	banList:AddColumn("Banned By")
	banList:SetHeaderHeight(30)
	banList:SetDataHeight(30)
	banList:SetMultiSelect(false)
	banList.OnRowRightClick = function(_, lineID)
		local line = banList:GetLine(lineID)
		local menu = DermaMenu()

		local copyName = menu:AddOption("Copy Name")
		copyName:SetIcon("icon16/page_copy.png")
		copyName.DoClick = function()
			SetClipboardText(line:GetColumnText(1))
			notification.AddLegacy("Copied Name!", NOTIFY_GENERIC, 2)
		end

		local copySteamID = menu:AddOption("Copy SteamID")
		copySteamID:SetIcon("icon16/page_copy.png")
		copySteamID.DoClick = function()
			SetClipboardText(line:GetColumnText(2))
			notification.AddLegacy("Copied SteamID!", NOTIFY_GENERIC, 2)
		end

		local copyReason = menu:AddOption("Copy Reason")
		copyReason:SetIcon("icon16/page_copy.png")
		copyReason.DoClick = function()
			SetClipboardText(line:GetColumnText(4))
			notification.AddLegacy("Copied Reason!", NOTIFY_GENERIC, 2)
		end

		local copyDate = menu:AddOption("Copy Date")
		copyDate:SetIcon("icon16/page_copy.png")
		copyDate.DoClick = function()
			SetClipboardText(line:GetColumnText(5))
			notification.AddLegacy("Copied Date!", NOTIFY_GENERIC, 2)
		end

		menu:AddSpacer()

		local editBanSubMenu, editBanOption = menu:AddSubMenu("Edit Ban...")
		editBanOption:SetIcon("icon16/user_edit.png")

		local editDuration = editBanSubMenu:AddOption("Edit Duration")
		editDuration:SetIcon("icon16/clock_edit.png")
		editDuration.DoClick = function()
			print("there is nothing")
		end

		local unbanPlayer = editBanSubMenu:AddOption("Unban Player")
		unbanPlayer:SetIcon("icon16/user_delete.png")
		unbanPlayer.DoClick = function()
			print("there is nothing")
		end

		menu:Open()
	end

	self.banList = banList
end

function bansMenu:AddPlayer(name, steamID, duration, reason, date, bannedByName)
	self.banList:AddLine(name, steamID, tostring(duration), reason, date, bannedByName)
end

function bansMenu:GetBans(pageNum)
	net.Start("bsu_request_bans")
	net.WriteUInt(pageNum, 8)
	net.SendToServer()
end

function bansMenu:LoadPage(pageNum)
	self.banList:Clear()
	self:GetBans(pageNum)
end

function bansMenu:PreviousPage()
	-- Don't scroll if already on the first page
	if self.currentPage - 1 < 1 then return end
	self.currentPage = self.currentPage - 1
	self.currentPageLabel:SetText("Page: " .. self.currentPage)
	self:LoadPage(self.currentPage)
end

function bansMenu:NextPage()
	-- Don't scroll when there are less than 50 results
	if #self.bans < 50 then return end
	self.currentPage = self.currentPage + 1
	self.currentPageLabel:SetText("Page: " .. self.currentPage)
	self:LoadPage(self.currentPage)
end

net.Receive("bsu_request_bans", function()
	BSU.BansMenu.bans = {}
	local banAmount = net.ReadUInt(6)
	for i = 1, banAmount do
		BSU.BansMenu.bans[i] = {}
		local banKeys = net.ReadUInt(4)
		for _ = 1, banKeys do
			local key = net.ReadString()
			local value = net.ReadType()
			BSU.BansMenu.bans[i][key] = value
		end
	end

	for _, ban in ipairs(BSU.BansMenu.bans) do
		BSU.BansMenu:AddPlayer(ban.identity, ban.identity, ban.duration, ban.reason and ban.reason or "[No Reason]", ban.time, ban.admin and ban.admin or "[Console]")
	end
end)

vgui.Register("BSUBansMenu", bansMenu, "DPanel")

hook.Add("BSU_BSUMenuInit", "BSU_BansMenuInit", function(bsuMenu)
	-- Only create tab if you're a superadmin
	if not LocalPlayer():IsUserGroup("superadmin") then return end
	local banMenu = vgui.Create("BSUBansMenu", bsuMenu)
	BSU.BansMenu = banMenu
	bsuMenu:AddTab("Ban History", 4, banMenu, "icon16/shield.png")
	BSU.BansMenu:LoadPage(1)
end)