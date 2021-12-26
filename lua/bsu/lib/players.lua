-- lib/players.lua (SHARED)

function BSU.GetPlayerTotalTime(ply)
  return ply:GetNW2Int("BSU_TotalTime") + BSU.UTCTime() - ply:GetNW2Int("BSU_ConnectTime")
end

function BSU.UTCToPlayerLocalTime(ply, utcTime)
  return utcTime + ply:GetNW2Int("BSU_TimeOffset") * 3600
end