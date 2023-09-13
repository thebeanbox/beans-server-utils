local groupsMenu = {}

function groupsMenu:Init()
	self:Dock(FILL)

	self.groups = {}
	self.teams = {}
	self.lastRefreshTime = SysTime()

	local ctrlPanel = vgui.Create("DPanel", self)
	ctrlPanel:Dock(TOP)
	ctrlPanel:SetHeight(25)
	self.ctrlPanel = ctrlPanel

	local ctrlReloadButton = vgui.Create("DButton", ctrlPanel)
	ctrlReloadButton:SetIcon("icon16/page_refresh.png")
	ctrlReloadButton:SetText("")
	ctrlReloadButton:Dock(LEFT)
	ctrlReloadButton:SetWidth(25)
	ctrlReloadButton.DoClick = function() self:Redraw() end
	self.ctrlPanelReloadButton = ctrlReloadButton

	local ctrlHint = vgui.Create("DLabel", ctrlPanel)
	ctrlHint:SetText("Reload page || Refresh database (forces reload)")
	ctrlHint:Dock(LEFT)
	ctrlHint:SetWidth(290)
	ctrlHint:SetTextColor(color_black)
	self.ctrlPanelHint = ctrlHint

	local ctrlRefreshButton = vgui.Create("DButton", ctrlPanel)
	ctrlRefreshButton:SetIcon("icon16/database_refresh.png")
	ctrlRefreshButton:SetText("")
	ctrlRefreshButton:Dock(LEFT)
	ctrlRefreshButton:SetWidth(25)
	ctrlRefreshButton.DoClick = function() self:Refresh() end

	local lastRefreshTimestamp = vgui.Create("DLabel", ctrlPanel)
	lastRefreshTimestamp:Dock(LEFT)
	lastRefreshTimestamp:SetWidth(300)
	lastRefreshTimestamp:SetTextColor(color_black)
	lastRefreshTimestamp.Think = function()
		self:SetText("last refresh: " .. math.Round(SysTime() - BSU.GroupsMenu.lastRefreshTime, 1) .. "s ago.")
	end
	self.lastRefreshTimestampLabel = lastRefreshTimestamp

	local debugLabel = vgui.Create("DLabel", ctrlPanel)
	debugLabel:Dock(RIGHT)
	debugLabel.Think = function()
		debugLabel:SetText("g:" .. table.Count(BSU.GroupsMenu.groups) .. "&t:" .. table.Count(BSU.GroupsMenu.teams))
	end

	local groupsPanel = vgui.Create("DPanel", self)
	groupsPanel:SetWidth(ScrW() * 0.39)
	groupsPanel:Dock(LEFT)
	   local teamsPanel = vgui.Create("DPanel", self)
	teamsPanel:SetWidth(ScrW() * 0.2)
	   teamsPanel:Dock(RIGHT)


	local groupList = vgui.Create("DProperties", groupsPanel)
	groupList:Dock(FILL)
	function groupList:RefreshGroups()
		self:Clear()
		for k, v in pairs(BSU.GroupsMenu.groups) do
			local def_team = self:CreateRow(k, "Default Team")
			def_team:Setup("integer")
			def_team:SetValue(v.team)
			def_team:SetEnabled(false)

			local ug = self:CreateRow(k, "Usergroup")
			ug:Setup("string")
			ug:SetValue(v.usergroup)
			ug:SetEnabled(false)

			local inheritinfo = self:CreateRow(k, "Inherits from")
			inheritinfo:Setup("string")
			inheritinfo:SetValue(v.inherit)
			inheritinfo:SetEnabled(false)

			local onlineplys = self:CreateRow(k, "Online players")
			onlineplys:Setup("integer")
			onlineplys:SetValue(table.Count(v.plys))
			onlineplys:SetEnabled(false)
		end
		self:InvalidateLayout()
	end

	self.groupsPanel = groupsPanel
	self.groupList = groupList

	local teamList = vgui.Create("DProperties", teamsPanel)
	teamList:Dock(FILL)
	function teamList:RefreshTeams()
		self:Clear()
		for k, v in pairs(BSU.GroupsMenu.teams) do
			local tcatName = "Team: " .. v.Name .. " (" .. k .. ")"

			local teamid = self:CreateRow(tcatName, "Team ID")
			teamid:Setup("integer")
			teamid:SetValue(k)
			teamid:SetEnabled(false)

			local joinable = self:CreateRow(tcatName, "Joinable")
			joinable:Setup("boolean")
			joinable:SetValue(v.Joinable)
			joinable:SetEnabled(false)

			local onlineplys = self:CreateRow(tcatName, "Online players")
			onlineplys:Setup("integer")
			onlineplys:SetValue(table.Count(team.GetPlayers(k)))
			onlineplys:SetEnabled(false)
		end
		self:InvalidateLayout()
	end
	self.teamsPanel = teamsPanel
	self.teamList = teamList
end
function groupsMenu:Redraw()
	self.groupList:RefreshGroups()
	self.teamList:RefreshTeams()
end

function groupsMenu:Refresh()
	notification.AddLegacy("Refreshing groupsMenu... (this may take a few seconds)", NOTIFY_GENERIC, 3)
	self.groups = {}
	self.teams = {}
	self:GetGroupsData()
	self:GetTeamsData()
	self.lastRefreshTime = SysTime()
	self:Redraw()
end

function groupsMenu:GetGroupsData()
	net.Start("bsu_request_groups")
	net.SendToServer()
end
function groupsMenu:GetTeamsData()
	for teamK, teamV in pairs(team.GetAllTeams()) do
		self.teams[teamK] = teamV
	end
end


net.Receive("bsu_request_groups", function()
	local newGroups = {}
	local groupCount = net.ReadUInt(8)
	for _ = 0, groupCount do
		local gId = net.ReadString()
		local gTeam = net.ReadInt(9)
		local gUserGroup = net.ReadString()
		local gInherit = net.ReadString()
		local gPlys = team.GetPlayers(gTeam) or 0
		newGroups[gId] = {
			team = gTeam,
			usergroup = gUserGroup,
			inherit = gInherit,
			plys = gPlys -- only online players
		}
	end
	BSU.GroupsMenu.groups = newGroups
	BSU.GroupsMenu:Redraw()
end)

vgui.Register("BSUGroupsMenu", groupsMenu, "DPanel")

hook.Add("BSU_BSUMenuInit", "BSU_GroupsMenuInit", function(bsuMenu)
	if not LocalPlayer():IsUserGroup("superadmin") then return end
	local BSUgroupsMenu = vgui.Create("BSUGroupsMenu", bsuMenu)
	BSU.GroupsMenu = BSUgroupsMenu
	bsuMenu:AddTab("Group Management", 3, BSUgroupsMenu, "icon16/group.png")
end)