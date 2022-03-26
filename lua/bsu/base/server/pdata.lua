-- base/server/pdata.lua

local function networkPData(ply)
  for k, v in pairs(BSU.GetAllPData(ply)) do
    ply:SetNW2String("BSU_PDATA_" .. k, v)
  end
end

hook.Add("PlayerInitialSpawn", "BSU_NetworkPData", networkPData)