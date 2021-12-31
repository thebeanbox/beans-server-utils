--[[
  Simple info display to view the owner of the prop and ect.
]]

local font = "BSU_PP_HUD"
surface.CreateFont(font, {
  font = "Verdana",
  size = 16,
  weight = 400,
  antialias = true,
  shadow = true
})

hook.Add("HUDPaint", "BSU_DrawPPHUD", function()
  if not IsValid(LocalPlayer()) then return end

  local trace = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
  if trace.HitNonWorld then
    local ent = trace.Entity
    if IsValid(ent) and not ent:IsPlayer() then
      local owner = BSU.GetEntityOwner(ent)
      
      local text = "Owner: " .. (owner and BSU.GetEntityOwnerName(ent) .. (BSU.GetEntityOwnerID(ent) and "<" .. BSU.GetEntityOwnerID(ent) .. ">" or "") or "N/A") .. "\n" ..
        ent:GetModel() .. "\n" ..
        tostring(ent)

      surface.SetFont(font)
      local w, h = surface.GetTextSize(text)
      draw.RoundedBox(4, ScrW() - w - 8, ScrH() / 2 - h / 2 - 4, w + 8, h + 8, Color(0, 0, 0, 175))
      draw.DrawText(text, font, ScrW() - 4, ScrH() / 2 - h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
    end
  end
end)
