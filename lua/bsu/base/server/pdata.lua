-- base/server/pdata.lua

local function networkPData(ply)
  for k, v in pairs(BSU.GetAllPData(ply), true) do -- get only networked data
    ply:SetNW2String("BSU_PDATA_" .. k, v)
  end
end

hook.Add("BSU_ClientReady", "BSU_NetworkPData", networkPData)