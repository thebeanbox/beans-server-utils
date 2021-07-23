// this is less resource intensive and less annoying to make work because networking is not necessary
/*
surface.CreateFont("BSU_NameTagText",
  {
    font = "Arial",
    extended = true,
    size = 25,
    weight = 600
  }
)

local function getDistanceAlpha(ply, dist1, dist2)
  return math.max(255 - (255 / dist2) * (math.max(LocalPlayer():GetPos():Distance(ply:GetPos()), dist1) - dist1), 0)
end

local materialData = {}

hook.Add("HUDPaint", "BSU_DrawNameTag", function()
  local players = player.GetAll()
  table.sort(players, function(a, b) return LocalPlayer():GetPos():Distance(a:GetPos()) > LocalPlayer():GetPos():Distance(b:GetPos()) end)

  for _, ply in ipairs(players) do
    if ply == LocalPlayer() then continue end

    local pos
    local ragdoll = ply:GetRagdollEntity()

    if ply:Alive() or not ragdoll:IsValid() then -- get the world pos of the player's head or the death ragdoll's head
      pos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1")) + Vector(0, 0, 20)
    else
      pos = ragdoll:GetBonePosition(ragdoll:LookupBone("ValveBiped.Bip01_Head1")) + Vector(0, 0, 20)
    end
    if not pos then continue end

    local data2D = pos:ToScreen()
    if not data2D.visible then continue end

    surface.SetFont("BSU_NameTagText")
    local w, h = surface.GetTextSize(ply:Nick()) -- get size of text
      
    -- draw name
    local nameAlpha = getDistanceAlpha(ply, 3000, 2000)
    draw.SimpleTextOutlined(ply:Nick(), "BSU_NameTagText", data2D.x, data2D.y, ColorAlpha(BSU:GetPlayerColor(ply), nameAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, ColorAlpha(color_black, nameAlpha))
    
    surface.SetDrawColor(ColorAlpha(color_white, getDistanceAlpha(ply, 500, 100)))
    BSU:SetPlayerAvatarMaterial(ply)

    -- draw avatar
    surface.DrawRect(data2D.x - w / 2 - 36, data2D.y - h - 4, 32, 32)
    surface.DrawTexturedRect(data2D.x - w / 2 - 36, data2D.y - h - 4, 32, 32)

    -- draw status icons
    local statuses = BSU:GetPlayerValues(ply)

    for k, v in ipairs(table.Reverse(statuses)) do
      local icoX, icoY = (20 * k) - 4 + v.offset.x, v.offset.y

      if materialData[v.type] then
        if materialData[v.type].path != v.image then
          materialData[v.type].path = v.image
          materialData[v.type].mat = Material(v.image)
        end
      else
        materialData[v.type] = {
          path = v.image,
          mat = Material(v.image)
        }
      end
      
      surface.SetMaterial(materialData[v.type].mat)
      surface.DrawTexturedRect(data2D.x - w / 2 - 48 + icoX, data2D.y + 8 + icoY, v.size.x, v.size.y)
    end
  end
  draw.NoTexture()
end)