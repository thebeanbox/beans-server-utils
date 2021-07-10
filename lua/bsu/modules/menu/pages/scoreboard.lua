surface.CreateFont( "BSU_ScoreboardPlayerName", {
	font = "Coolvetica",
	extended = true,
  antialias = true,
	size = 18,
	weight = 1000,
})

local function getPlayersOrganized()
  local players, teams = {}, table.GetKeys(team.GetAllTeams())

  table.sort(teams, function(a, b) return a > b end)

  for _, v in ipairs(teams) do
    table.Add(players, team.GetPlayers(v))
  end

  return players
end

local panel = vgui.Create("DPanel")
panel.Paint = function() end

local list = vgui.Create("DCategoryList", panel)
list.Paint = function() end
list:Dock(FILL)

hook.Add("Think", list, function(self)
  local players, rows = getPlayersOrganized(), list:GetChildren()[1]:GetChildren()

  for i = 1, #players do
    if not rows[i]:IsVisible() then
      rows[i]:SetVisible(true)
    end
  end

  for i = #players + 1, game.MaxPlayers() do
    if rows[i]:IsVisible() then
      rows[i]:SetVisible(false)
    end
  end
end)

for i = 1, game.MaxPlayers() do
  local row = vgui.Create("DCollapsibleCategory")
  row:SetHeaderHeight(36)
  row:SetExpanded(false)
  row:SetLabel("")
  row:DockMargin(0, 0, 0, 5)
  row.Paint = function(self, w, h)
    local player = getPlayersOrganized()[i]
    if player then
      draw.RoundedBox(5, 0, 0, w, h, team.GetColor(player:Team()))
      draw.SimpleTextOutlined(
        player:Nick(),
        "BSU_ScoreboardPlayerName",
        39,
        9,
        color_white,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_TOP,
        2,
        color_black
      )
    end
  end
  list:AddItem(row)

  local avatar = vgui.Create("AvatarImage", row)
	avatar:SetSize(30, 30)
	avatar:SetPos(3, 3)
	hook.Add("Think", avatar, function(self)
    local player = getPlayersOrganized()[i]
    self:SetPlayer(player, 64)
  end)

  local contents = vgui.Create("DPanel")
  contents:SetTall(100)
  contents:Dock(FILL)
  local label = vgui.Create("DLabel", contents)
  label:Dock(TOP)

  row:SetContents(contents)
end

bsuMenu.addPage(2, "Scoreboard", panel, "icon16/controller.png")