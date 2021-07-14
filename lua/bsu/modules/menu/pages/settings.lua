local panel = vgui.Create("DPanel")
panel.Paint = function() end

-- DEVTESTING FUNCTIONS, PLEASE FUCKING REMOVE THESE BEFORE THE SERVER GOES PUBLIC

local entry1 = vgui.Create("DNumberWang", panel)
hook.Add("InitPostEntity", "BSU_LayoutDevSettings", function()
  entry1:Dock(TOP)
  entry1:SetDecimals(0)
  entry1:SetMinMax(100, 112)
  entry1:SetPos(85, 25)
  entry1.OnValueChanged = function(self)
    LocalPlayer():SetTeam(self:GetValue())
  end
end )
local entry2 = vgui.Create("DLabel")
entry2:SetText("Set Team")
entry2:SetPos(15, 25)

bsuMenu.addPage(3, "Settings", panel, "icon16/cog.png")
