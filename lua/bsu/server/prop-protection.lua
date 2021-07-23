
hook.Add("PhysgunPickup", "BSU_PropProtectPhysgun", function(ply, ent)
  if BSU:PlayerIsSuperAdmin(ply) then return true end

  if IsValid(ent:GetOwner()) and ent:GetOwner() == ply then
    return true
  end

  return false
end)

hook.Add("OnPhysgunPickup", "BSU_PlayerPhysgunPickup", function(ply, ent)
  if ent:IsPlayer() then
    ent:SetMoveType(MOVETYPE_NONE)
  end
end)
hook.Add("PhysgunDrop", "BSU_PlayerPhysgunDrop", function(ply, ent)
  if ent:IsPlayer() then
    ent:SetMoveType(MOVETYPE_WALK)
  end
end)