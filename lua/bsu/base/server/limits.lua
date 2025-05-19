-- base/server/limits.lua

local function checkLimit(ply, limitName, currAmt)
	if ply:IsSuperAdmin() then return true end
	local amt = BSU.GetPlayerLimit(ply:SteamID64(), limitName, true) -- also check wildcards
	if amt then return amt < 0 or currAmt < amt end
end

hook.Add("PlayerCheckLimit", "BSU_CheckLimit", checkLimit)
