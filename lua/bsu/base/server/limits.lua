-- base/server/limits.lua

local function checkLimit(ply, limitName, currAmt)
  local amt = BSU.GetPlayerLimit(ply:SteamID64(), limitName)
  if amt then return amt < 0 or currAmt < amt end
end

hook.Add("PlayerCheckLimit", "BSU_CheckLimit", checkLimit)