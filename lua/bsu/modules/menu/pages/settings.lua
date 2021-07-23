if SERVER then

else
  local panel = vgui.Create("DPanel")
  panel.Paint = function() end

  local entry = vgui.Create("DTextEntry", panel)
  entry:SetTabbingDisabled(true) -- this is needed because you have to be holding TAB to open the menu
  entry:Dock(TOP)

  bsuMenu.addPage(999, "Settings", panel, "icon16/cog.png") -- large index so it's the last tab
end