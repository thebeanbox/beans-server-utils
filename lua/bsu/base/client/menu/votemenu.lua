local voteMenu = {}

function voteMenu:Init()
	self:Dock(FILL)
	self:SetDividerWidth(2)
	self:SetLeftMin(100)
	self:SetRightMin(100)
	self:SetLeftWidth(200)
end

vgui.Register("BSUVoteMenu", voteMenu, "DHorizontalDivider")

hook.Add("BSU_BSUMenuInit", "BSU_VoteMenuInit", function(bsuMenu)
	--local voteMenu = vgui.Create("BSUVoteMenu", bsuMenu)
	--bsuMenu:AddTab("Voting", 2, voteMenu, "icon16/chart_bar.png")
end)