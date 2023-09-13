-- lib/players.lua (SHARED)

function BSU.GetPlayerTotalTime(ply)
	return tonumber(BSU.GetPData(ply, "total_time"))
end

function BSU.UTCToPlayerLocalTime(ply, utcTime)
	return (utcTime or BSU.UTCTime()) + tonumber(BSU.GetPData(ply, "timezone")) * 3600
end
