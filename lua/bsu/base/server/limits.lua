-- base/server/limits.lua

local function checkLimit(ply, limitName, currAmt)
  if BSU.IsPlayerLimited(ply, limitName, currAmt) then
    return false
  end
end

hook.Add("PlayerCheckLimit", "BSU_CheckLimit", checkLimit)