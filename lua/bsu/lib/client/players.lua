-- lib/client/players.lua

util.AddNetworkString("bsu_client_info")

function BSU.SendClientInfo()
	net.Start("bsu_client_info")
		net.WriteUInt(system.IsWindows() and 0 or system.IsLinux() and 1 or system.IsOSX() and 2 or 3, 2) -- operating system (or N/A)
		net.WriteString(system.GetCountry()) -- 2 letter country code
		net.WriteFloat((BSU.UTCTime() - BSU.LocalTime()) / 3600 + (os.date("*t").isdst and 1 or 0)) -- UTC timezone offset
	net.SendToServer()
end