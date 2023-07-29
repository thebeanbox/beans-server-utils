-- base/server/pdata.lua

local function networkPData(ply)
	for k, v in pairs(BSU.GetAllPData(ply), true) do -- get only networked data
		ply:SetNWString("bsu_" .. k, v)
	end
end

hook.Add("BSU_PlayerReady", "BSU_NetworkPData", networkPData)