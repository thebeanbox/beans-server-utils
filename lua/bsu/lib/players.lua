-- lib/players.lua (SHARED)

function BSU.GetPlayerTotalTime(ply)
	return BSU.GetPDataNumber(ply, "total_time", 0)
end

function BSU.UTCToPlayerLocalTime(ply, utcTime)
	return (utcTime or BSU.UTCTime()) + BSU.GetPDataNumber(ply, "timezone", 0) * 3600
end
