local panel = vgui.Create("DPanel")
panel.Paint = function() end

-- DEVTESTING FUNCTIONS, PLEASE FUCKING REMOVE THESE BEFORE THE SERVER GOES PUBLIC

local entry1 = vgui.Create("DNumSlider", panel)
entry1:SetTabbingDisabled(true) -- this is needed because you have to be holding TAB to open the menu
entry1:Dock(TOP)
entry1:SetText("Team Setter (dev function)")
entry1:SetMinMax(100, 108)
entry1:SetDefaultValue(LocalPlayer():Team())
entry1:SetConVar("bsu_SetPlayerRank \"" .. LocalPlayer():Nick() .. "\"")

bsuMenu.addPage(3, "Settings", panel, "icon16/cog.png")
