--[[
  Simple info display to view the owner of the prop and ect.
]]

local font = "PropProtection_Font"
surface.CreateFont(font, {
  font = "Verdana",
  size = 16,
  weight = 400,
  antialias = true,
  shadow = true
})

hook.Add("HUDPaint", "BSU_PropProtectHUD", function()
  if not IsValid(LocalPlayer()) then return end

  local tr = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
  if tr.HitNonWorld then
    if IsValid(tr.Entity) and not tr.Entity:IsPlayer() and not LocalPlayer():InVehicle() then
      local Owner = tr.Entity:GetNWEntity("OwnerEnt")
      local Nick = "Owner:" .. (IsValid(Owner) and Owner:Nick() .. "[" .. Owner:EntIndex() .. "]" .. "\n[" .. Owner:SteamID() .. "]" or tr.Entity:GetNWString("Owner", "N/A"))

      local Info = Nick .. "\n[" .. tr.Entity:EntIndex() .. "]" .. tr.Entity:GetModel() .. "\n<" .. tr.Entity:GetClass() .. ">"

      
      surface.SetFont(font)
      local w, h = surface.GetTextSize(Info)
      w = w + 6
      surface.SetDrawColor(0, 0, 0, 150)
      surface.DrawRect(ScrW() - w, ScrH() / 2 - h / 2, w + 8, h + 8)
      draw.DrawText(Info, font, ScrW() - w / 2, ScrH() / 2 - h / 2, Color(255, 255, 255, 255), 1, 1)
    end
  end
end)
