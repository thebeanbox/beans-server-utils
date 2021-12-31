--[[
  Tab menu/scoreboard

  If you want to add something to the tab menu then you need to add the panel after the 'BSU_LoadTabMenu' hook gets called
    or put the script in the pages folder
]]

local pageFiles = file.Find(BSU.DIR_MODULES .. "pages/" .. "*.lua", "LUA")

if SERVER then
  -- Include all page files
  for _, pageFile in ipairs(pageFiles) do
    include(BSU.DIR_MODULES .. "pages/" .. pageFile)
    AddCSLuaFile(BSU.DIR_MODULES .. "pages/" .. pageFile)
  end
  return
end

BSU.Menu = BSU.Menu or {}

local tabMenu = BSU.Menu

local function tabOnPaint(self, w, h)
  draw.RoundedBoxEx(5, 0, 0, w, h, Color(40, 40, 40), true, true)
end
local function tabOffPaint(self, w, h)
  draw.RoundedBoxEx(5, 0, 0, w, h, Color(10, 10, 10), true, true)
end

local function init()
  local panel = vgui.Create("DFrame")
  panel:SetSize(ScrW() * 0.85, ScrH() * 0.85)
  panel:Center()
  panel:SetTitle("")
  panel:SetDraggable(false)
  panel:ShowCloseButton(false)
  panel:SetVisible(false)
  panel:DockPadding(6, 6, 6, 6)
  function panel:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, Color(20, 20, 20))
  end

  tabMenu.panel = panel

  local sheet = vgui.Create("DPropertySheet", panel)
  sheet:Dock(FILL)
  sheet:DockPadding(0, 0, 0, 0)
  function sheet:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40))
  end

  function sheet:OnActiveTabChanged(old, new)
    old.Paint = tabOffPaint
    new.Paint = tabOnPaint
  end

  function sheet.tabScroller:AddPanel(pnl)
    if not self.RealPanels then self.RealPanels = {} end
    self.RealPanels[pnl:GetPanel().Index] = pnl

    local newPanels = {}
    for _, panel in ipairs(self.RealPanels) do
      table.insert(newPanels, panel)
    end

    self.Panels = newPanels

    pnl:SetParent(self.pnlCanvas)
    self:InvalidateLayout(true)
  end

  tabMenu.sheet = sheet

  local KeepOpenTypes = {
    ["TextEntry"] =  true,
    ["HtmlPanel"] = true
  }

  hook.Add("VGUIMousePressed", "BSU_MenuClick", function(pnl)
    if pnl:GetClassName() == "CGModBase" then
      tabMenu.hide()
    elseif pnl:HasParent(tabMenu.sheet) and KeepOpenTypes[pnl:GetClassName()] then
      tabMenu.panel:SetKeyboardInputEnabled(true)
    end
  end)
end

function tabMenu.show()
  tabMenu.panel:SetVisible(true)
  tabMenu.panel:MakePopup()
  tabMenu.panel:SetKeyboardInputEnabled(false)
end
function tabMenu.hide()
  tabMenu.panel:SetVisible(false)
  gui.EnableScreenClicker(false)
  tabMenu.panel:SetKeyboardInputEnabled(false)
end

function tabMenu.addPage(index, name, panel, icon)
  panel.Index = index
  local tblData = tabMenu.sheet:AddSheet(name, panel, icon)
  tblData.Tab.Paint = tblData.Tab:IsActive() and tabOnPaint or tabOffPaint

  return tblData
end

hook.Add("Think", "BSU_HideTabMenu", function()
  if tabMenu.panel:IsVisible() and gui.IsGameUIVisible() then
    gui.HideGameUI()
    tabMenu.hide()
  end
end)

hook.Add("Initialize", "BSU_MenuInit", function()
  init()
  
  GAMEMODE.ScoreboardShow = tabMenu.show
  GAMEMODE.ScoreboardHide = function()
    if tabMenu.panel:IsVisible() and not tabMenu.panel:IsKeyboardInputEnabled() then
      tabMenu.hide()
    end
  end

  -- Run page files
  for _, pageFile in ipairs(pageFiles) do
    include(BSU.DIR_MODULES .. "pages/" .. pageFile)
  end

  hook.Run("BSU_LoadTabMenu")
end)