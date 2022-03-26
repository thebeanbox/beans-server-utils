-- lib/client/pdata.lua

-- gets a pdata value on a player (or nothing if it's not set)
function BSU.GetPData(ply, key)
  local val = (ply or LocalPlayer()):GetNW2String("BSU_PDATA_" .. key, false)
  if val then return val end
end