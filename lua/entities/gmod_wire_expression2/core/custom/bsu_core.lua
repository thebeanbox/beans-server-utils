if SERVER then
  E2Lib.RegisterExtension("bsu", false, "BSU E2 functions (W.I.P, dev functions)", "this extension has unrestricted access to functions that you should, under no circumstance, let the server go public with!")
  e2function vector bsuGetPlayerColor(entity player)
    if player:IsValid() then
      local color = BSU:GetPlayerColor(player)
      return Vector(color.r, color.g, color.b)
    end
  end
end
