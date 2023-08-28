local function createBSUMenu()
	if BSU.BSUMenu then BSU.BSUMenu:Remove() end
	
	local bsuMenu = vgui.Create("BSUMenu")
	BSU.BSUMenu = bsuMenu
	hook.Run("BSU_BSUMenuInit", bsuMenu)
	bsuMenu:InitializeTabs()
	hook.Run("BSU_BSUMenuPostInit", bsuMenu)
end

BSU.SetupCommand("menu", function(cmd)
	cmd:SetDescription("Opens the menu")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ANYONE)
	cmd:SetFunction(function(self, caller)
		if not BSU.BSUMenu then createBSUMenu() end
		BSU.BSUMenu:Center()
		BSU.BSUMenu:Show()
		BSU.BSUMenu:MakePopup()
	end)
end)

BSU.SetupCommand("menuregen", function(cmd)
	cmd:SetDescription("Regenerates the menu")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ANYONE)
	cmd:SetFunction(function(self, caller)
		if BSU.BSUMenu then
			BSU.BSUMenu:Remove()
		end
		createBSUMenu()
	end)
end)