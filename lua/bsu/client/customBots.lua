local model = ClientsideModel("models/food/hotdog.mdl")
model:SetNoDraw(true)

hook.Add("PostDrawTranslucentRenderables", "BSU_CustomBots", function()
  for _, ply in ipairs(player.GetAll()) do
    if not ply or not ply:IsValid() or not ply:IsBot() then continue end
    
    local pos, ang
    local ragdoll = ply:GetRagdollEntity()

    if ply:Alive() or not ragdoll:IsValid() then
      pos, ang = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Pelvis"))
    else
      pos, ang = ragdoll:GetBonePosition(ragdoll:LookupBone("ValveBiped.Bip01_Pelvis"))
    end
    if not pos or not ang then continue end

    pos = pos + ang:Right() * 18 + ang:Up() * 8
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Right(), -90)
        
    model:SetPos(pos)
    model:SetAngles(ang)
    model:SetupBones()
    model:DrawModel()
  end
end)