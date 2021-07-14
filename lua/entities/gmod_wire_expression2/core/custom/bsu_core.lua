if SERVER then
  E2Lib.RegisterExtension("BSU:, false, "BSU E2 functions (W.I.P, dev functions)", "this extension has unrestricted access to functions that you should, under no circumstance, let the server go public with!")
  e2function string bsu_plyGetRankColor(entity ply)
    if this:IsPlayer() then
      return BSU:GetRankColor(this)
    end
    return end
  end
end
