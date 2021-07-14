surface.CreateFont( "BSU_ScoreboardText", {
	font = "Arial",
	extended = true,
  antialias = true,
	size = 20,
	weight = 800,
})

local gradient = Material("gui/gradient")

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

local list = vgui.Create("DScrollPanel", panel)
list:Dock(FILL)

hook.Add("Think", list, function(self)
  local totalPlayers, listRows = #getPlayersOrganized(), self:GetChildren()[1]:GetChildren()

  for i = 1, totalPlayers do
    if not listRows[i]:IsVisible() then
      listRows[i]:SetVisible(true)
    end
  end
  for i = totalPlayers + 1, game.MaxPlayers() do
    if listRows[i]:IsVisible() then
      listRows[i]:SetVisible(false)
    end
  end
end)

list.Paint = function(self, w, h)
  draw.RoundedBox(0, 0, 0, w, 36, color_black)

  draw.SimpleText(
    "Name",
    "BSU_ScoreboardText",
    41,
    18,
    color_white,
    TEXT_ALIGN_LEFT,
    TEXT_ALIGN_CENTER
  )

  draw.SimpleText(
    "Rank",
    "BSU_ScoreboardText",
    w / 2,
    18,
    color_white,
    TEXT_ALIGN_CENTER,
    TEXT_ALIGN_CENTER
  )

  draw.SimpleText(
    "Health",
    "BSU_ScoreboardText",
    w / 2 + 150,
    18,
    color_white,
    TEXT_ALIGN_CENTER,
    TEXT_ALIGN_CENTER
  )

  draw.SimpleText(
    "K/D",
    "BSU_ScoreboardText",
    w / 2 + 300,
    18,
    color_white,
    TEXT_ALIGN_CENTER,
    TEXT_ALIGN_CENTER
  )

  draw.SimpleText(
    "Play Time",
    "BSU_ScoreboardText",
    w / 2 + 450,
    18,
    color_white,
    TEXT_ALIGN_CENTER,
    TEXT_ALIGN_CENTER
  )

  draw.SimpleText(
    "Ping",
    "BSU_ScoreboardText",
    w / 2 + 600,
    18,
    color_white,
    TEXT_ALIGN_CENTER,
    TEXT_ALIGN_CENTER
  )
end

for i = 1, game.MaxPlayers() do
  local row = vgui.Create("DPanel")
  list:AddItem(row)
  row:Dock(TOP)
  row:SetTall(36)
  row:DockMargin(0, i == 1 and 36 or 0, 0, -1)

  row.Paint = function(self, w, h)
    if not self.player or not self.player:IsValid() then return end

    -- background
    draw.RoundedBox(0, 0, 0, w, 36, color_black)

    -- color
    draw.RoundedBoxEx(5, 2, 2, w - 4, 32, team.GetColor(self.player:Team()), true, false, true, false)

    surface.SetDrawColor(Color(0, 0, 0, 125))

    surface.SetMaterial(gradient)
    surface.DrawTexturedRect(2, 2, (w - 4) / 2, 32)
    surface.SetMaterial(gradient)
    surface.DrawTexturedRectUV(2 + (w - 4) / 2, 2, (w - 4) / 2, 32, 1, 0, 0, 1)

    -- avatar bg
    draw.RoundedBox(0, 0, 0, 36, 36, color_black)
    draw.RoundedBox(0, 2, 2, 32, 32, color_white)

    -- player name
    draw.SimpleText(
      self.player:Nick(),
      "BSU_ScoreboardText",
      41,
      18,
      color_black,
      TEXT_ALIGN_LEFT,
      TEXT_ALIGN_CENTER
    )

    -- player rank
    draw.SimpleText(
      team.GetName(self.player:Team()),
      "BSU_ScoreboardText",
      w / 2,
      18,
      color_black,
      TEXT_ALIGN_CENTER,
      TEXT_ALIGN_CENTER
    )

    -- health
    draw.SimpleText(
      math.max(math.Round(self.player:Health() / self.player:GetMaxHealth(), 2) * 100, 0) .. "%",
      "BSU_ScoreboardText",
      w / 2 + 150,
      18,
      color_black,
      TEXT_ALIGN_CENTER,
      TEXT_ALIGN_CENTER
    )

    -- kill/death ratio
    draw.SimpleText(
      math.Round((BSU:GetPlayerKills(self.player) + 1) / (self.player:Deaths() + 1), 2),
      "BSU_ScoreboardText",
      w / 2 + 300,
      18,
      color_black,
      TEXT_ALIGN_CENTER,
      TEXT_ALIGN_CENTER
    )

    -- total server playtime
    local playTime = BSU:GetPlayerPlayTime(self.player)
    local hours = string.format("%02.f", math.floor(playTime / 3600))
    local mins = string.format("%02.f", math.floor(playTime / 60 - (hours * 60)))
    local secs = string.format("%02.f", math.floor(playTime - hours * 3600 - mins * 60))

    draw.SimpleText(
      hours .. ":" .. mins .. ":" .. secs,
      "BSU_ScoreboardText",
      w / 2 + 450,
      18,
      color_black,
      TEXT_ALIGN_CENTER,
      TEXT_ALIGN_CENTER
    )

    -- ping
    draw.SimpleText(
      self.player:Ping(),
      "BSU_ScoreboardText",
      w / 2 + 600,
      18,
      color_black,
      TEXT_ALIGN_CENTER,
      TEXT_ALIGN_CENTER
    )
  end

  hook.Add("Think", row, function(self)
    self.player = getPlayersOrganized()[i]
    if not self.player or not self.player:IsValid() then return end

    self.avatar:SetPlayer(self.player, 64)

    local iconsData = {}

    if not self.player:IsBot() then
      -- append if linux user and if not bot
      local os = BSU:GetPlayerOS(self.player)
      if os != "" then
        table.insert(iconsData, {
          image = os == "windows" and "materials/bsu/scoreboard/windows.png" or os == "linux" and "icon16/tux.png" or os == "mac" and "materials/bsu/scoreboard/mac.png",
        })
      end

      -- append country flag icon if not bot
      local country = BSU:GetPlayerCountry(self.player)
      if country != "" then
        table.insert(iconsData, {
          image = "flags16/" .. country .. ".png",
          sizeY = 11,
          posY = 13
        })
      end
    end

    -- append status icon
    local status = BSU:GetPlayerStatus(self.player)
    table.insert(iconsData, {
      image = "icon16/status_" .. status .. ".png"
    })

    -- append mode (build or pvp)
    local mode = BSU:GetPlayerMode(self.player) == "build" and "wrench" or "gun"
    table.insert(iconsData, {
      image = "icon16/" .. mode .. ".png"
    })

    for k, v in ipairs(self.icons) do
      local data = iconsData[k]
      if data then
        v:SetImage(data.image)
        v:SetSize(data.sizeX or 16, data.sizeY or 16)
        v:SetPos(self:GetWide() - 20 * k - 4, data.posY or 10)

        if not v:IsVisible() then
          v:SetVisible(true)
        end
      elseif v:IsVisible() then
        v:SetVisible(false)
      end
    end
  end)

  -- player avatar
  row.avatar = vgui.Create("AvatarImage", row)
	row.avatar:SetSize(32, 32)
	row.avatar:SetPos(2, 2)

  row.avatarBtn = vgui.Create("DButton", row)
  row.avatarBtn:SetSize(32, 32)
	row.avatarBtn:SetPos(2, 2)
  row.avatarBtn:SetText("")
  row.avatarBtn.Paint = function() end
  row.avatarBtn.DoClick = function()
    if not row.player or not row.player:IsValid() then return end

    row.player:ShowProfile()
  end

  -- icons
  row.icons = {}
  for i = 1, 5 do
    table.insert(row.icons, vgui.Create("DImage", row))
  end
end

bsuMenu.addPage(2, "Scoreboard", panel, "icon16/controller.png") -- add this page to the client's menu as "Scoreboard"