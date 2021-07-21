-- avatarsManager.lua by Bonyoze

local function loadAvatar(ply)
  ply.bsuAvatar = vgui.Create("AvatarImage")
  ply.bsuAvatar:SetPos(0, 0)
  ply.bsuAvatar:SetSize(64, 64)
  ply.bsuAvatar:SetPlayer(ply, 64)
  ply.bsuAvatar:SetPaintedManually(true)
end

timer.Create("BSU_UpdateAvatars", 1, 0, function()
  for _, ply in ipairs(player.GetAll()) do
    if ply:IsBot() then continue end
    loadAvatar(ply)
  end
end)

local avatarRT = GetRenderTarget("BSU_AvatarRT", 64, 64)

local avatarPlayer = Material("BSU_PlayerAvatar")
local avatarDefault = Material("vgui/avatar_default")

function BSU:SetPlayerAvatarMaterial(ply)
  if not ply:IsBot() then
    render.PushRenderTarget(avatarRT)
    render.Clear(0, 0, 0, 255)
    cam.Start2D()

    if not ply.bsuAvatar then
      loadAvatar(ply)
    end
    ply.bsuAvatar:PaintManual()
    cam.End2D()
    render.PopRenderTarget()

    avatarPlayer:SetTexture("$basetexture", avatarRT)
    surface.SetMaterial(avatarPlayer)
  else
    surface.SetMaterial(avatarDefault)
  end
end

function BSU:GetPlayerAvatarData(ply)
  local imgData
  cam.Start2D()
  surface.SetDrawColor(color_white)
  
  if not ply:IsBot() then
    if not ply.bsuAvatar then
      loadAvatar(ply)
    end
    ply.bsuAvatar:PaintManual()
  else
    surface.SetTexture(surface.GetTextureID("vgui/avatar_default"))
    surface.DrawRect(0, 0, 64, 64)
    surface.DrawTexturedRect(0, 0, 64, 64)
  end

  imgData = render.Capture({
    format = "jpeg",
    x = 0,
    y = 0,
    w = 64,
    h = 64
  })
  cam.End2D()
  
  return imgData
end