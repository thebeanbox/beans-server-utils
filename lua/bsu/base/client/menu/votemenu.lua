local voteEntry = {}

function voteEntry:Init()
	self.opened = true
	self.openFactor = 0

	self.options = {}
	self.players = {}

	self:SetHeight(32)
	self:Dock(TOP)
end

function voteEntry:SetVote(vote)
	local title = vgui.Create("DButton", self)
	title:SetHeight(32)
	title:SetContentAlignment(5)
	title:SetTextColor(color_black)
	title:SetText(vote.title)
	title:Dock(TOP)

	function title.DoClick()
		self.opened = not self.opened
	end

	local dropDown = vgui.Create("DScrollPanel", self)
	dropDown:SetHeight(200)
	dropDown:Dock(FILL)
	self.dropDown = dropDown

	for i, opt in ipairs(vote.options) do
		local option = vgui.Create("DPanel", dropDown)
		option:SetHeight(32)
		option:Dock(TOP)
		self.options[i] = option

		local button = vgui.Create("DButton", option)
		button:SetText(opt)
		button:Dock(RIGHT)

		function button:DoClick()
			BSU.VoteFor(vote, i)
		end
	end
end

function voteEntry:PlayerVote(ply, optionIndex)
	local avatar = self.players[ply]
	if not avatar then
		avatar = vgui.Create("AvatarImage", 32)
		avatar:SetWidth(32)
		avatar:SetPlayer(ply)
		avatar:Dock(RIGHT)
		self.players[ply] = avatar
	end
	avatar:SetParent(self.options[optionIndex])
end

function voteEntry:Think()
	local dropDown = self.dropDown
	if not dropDown then return end

	if self.opened then
		if self.openFactor < 1 then
			self.openFactor = math.min(self.openFactor + FrameTime() * 2, 1)
			self:SetHeight(Lerp(self.openFactor, 0, 200) + 32)
		end
	elseif self.openFactor > 0 then
		self.openFactor = math.max(self.openFactor - FrameTime() * 2, 0)
		self:SetHeight(Lerp(self.openFactor, 0, 200) + 32)
	end
end

vgui.Register("BSUVoteEntry", voteEntry, "Panel")

local voteMenu = {}

function voteMenu:Init()
	self:Dock(FILL)

	self.entries = {}
end

function voteMenu:VoteStart(vote)
	local entry = vgui.Create("BSUVoteEntry", self)
	entry:SetVote(vote)
	self.entries[vote.id] = entry
end

function voteMenu:VoteEnd(vote)
	local entry = self.entries[vote.id]
	if not entry then return end

	entry:Remove()
	self.entries[vote.id] = nil
end

function voteMenu:PlayerVote(vote, ply, optionIndex)
	local entry = self.entries[vote.id]
	if not entry then return end

	entry:PlayerVote(ply, optionIndex)
end

vgui.Register("BSUVoteMenu", voteMenu, "DScrollPanel")

hook.Add("BSU_BSUMenuInit", "BSU_VoteMenuInit", function(bsuMenu)
	local voteTab = vgui.Create("BSUVoteMenu", bsuMenu)
	bsuMenu:AddTab("Voting", 2, voteTab, "icon16/chart_bar.png")
	BSU.VoteMenu = voteTab
end)

hook.Add("BSU_VoteStart", "BSU_VoteMenu", function(vote)
	if not BSU.VoteMenu then return end

	BSU.VoteMenu:VoteStart(vote)
	BSU.BSUMenu:SelectTab(2)
	BSU.BSUMenu:Open()
end)

hook.Add("BSU_VoteEnd", "BSU_VoteMenu", function(vote)
	if not BSU.VoteMenu then return end

	BSU.VoteMenu:VoteEnd(vote)
end)

hook.Add("BSU_PlayerVote", "BSU_VoteMenu", function(vote, ply, optionIndex)
	if not BSU.VoteMenu then return end

	BSU.VoteMenu:PlayerVote(vote, ply, optionIndex)
end)

