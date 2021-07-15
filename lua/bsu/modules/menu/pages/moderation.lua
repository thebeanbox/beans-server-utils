local panel = vgui.Create("DPanel")
panel.Paint = function() end

local entry = vgui.Create("DTextEntry", panel)
entry:SetTabbingDisabled(true) -- this is needed because you have to be holding TAB to open the menu
entry:Dock(TOP)

local TeamList = vgui.Create( "DListView", panel )
TeamList:Dock( FILL )
TeamList:SetMultiSelect( false )
TeamList:AddColumn( "Index" )
TeamList:AddColumn( "Team Name" )

local ranks = team.GetAllTeams()

for k, v in pairs(table.SortByKey(ranks)) do
    TeamList:AddLine(k, v.Name)
end

TeamList.OnRowSelected = function( lst, index, pnl )
	BSU:SetPlayerRank(LocalPlayer(), index)
end

bsuMenu.addPage(3, "Moderation", panel, "icon16/shield.png")
