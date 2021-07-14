local panel = vgui.Create("DPanel")
panel.Paint = function() end

-- DEVTESTING FUNCTIONS, PLEASE FUCKING REMOVE THESE BEFORE THE SERVER GOES PUBLIC

local entry1 = vgui.Create("DNumSlider", panel)
hook.Add("InitPostEntity", "BSU_LayoutDevSettings", function()
  entry1:Dock(TOP)
  entry1:SetText("Team Setter (dev function)")
  entry1:SetMinMax(100, 108)
  entry1:SetDefaultValue(LocalPlayer():Team())
  entry1:SetConVar("bsu_setPlayerRank", "\"" .. LocalPlayer():Nick() .. "\"")
end )

bsuMenu.addPage(3, "Settings", panel, "icon16/cog.png")
