local bansmenu = {}

function bansmenu:Init()
	self:Dock(FILL)

	self.bansPerPage = 50 -- 255 Max
	self.bansRemaining = 0
	self.page = 1
	
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

function bansmenu:RequestBanList()
	net.Start("bsu_request_banlist")
	net.WriteUInt(self.page, 8)
	net.WriteUInt(self.bansPerPage, 8)
	net.SendToServer()
end

function bansmenu:LoadPage(n)
	self:RequestBanList()
	self.banList:Clear()
	self.pageLabel:SetText("Page: " .. self.page)
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


vgui.Register("BSUBansMenu", bansmenu, "DPanel")

hook.Add("BSU_BSUMenuInit", "BSUBansMenuInit", function(bsuMenu)
	if not LocalPlayer():IsUserGroup("superadmin") then return end
	bansMenu = vgui.Create("BSUBansMenu", bsuMenu)
	bsuMenu:AddTab("Ban History", 4, bansMenu, "icon16/shield.png")
	BSU.BansMenu = bansMenu
end)