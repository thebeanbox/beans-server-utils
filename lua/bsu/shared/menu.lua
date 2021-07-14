-- menu.lua by Bonyoze

MENU_PAGES = "bsu/modules/menu/pages/"

if SERVER then
  AddCSLuaFile("bsu/modules/menu/frameManager.lua")

  local pageFiles = file.Find(MENU_PAGES .. "*.lua", "LUA")
  for _, file in ipairs(pageFiles) do
    AddCSLuaFile(MENU_PAGES .. file)
  end
else
  bsuMenu = bsuMenu or {}
  bsuMenu.pageFiles = file.Find(MENU_PAGES .. "*.lua", "LUA")

  include("bsu/modules/menu/frameManager.lua")
  
  hook.Add("OnGamemodeLoaded", "BSU_MenuInit", function()
    if not IsValid(bsuMenu.frame) then
      bsuMenu.create()
    end

    local function menuManage(open)
      if not bsuMenu.frame:IsKeyboardInputEnabled() then
        if open then
          if not bsuMenu.sheet:IsVisible() then
            bsuMenu.show()
          end
        else
          if bsuMenu.sheet:IsVisible() then
            bsuMenu.hide()
          end
        end
      end
    end

    function GAMEMODE:ScoreboardShow()
      menuManage(true)
    end
    
    function GAMEMODE:ScoreboardHide()
      menuManage(false)
    end
  end)
end