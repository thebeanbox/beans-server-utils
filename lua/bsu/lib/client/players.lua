-- lib/client/players.lua

function BSU.SendClientInfo()
  net.Start("BSU_ClientInfo")
    net.WriteUInt(system.IsWindows() and 0 or system.IsLinux() and 1 or system.IsOSX() and 2 or 3, 2) -- operating system (or 3 if N/A)
    net.WriteString(system.GetCountry()) -- 2 letter country code
    net.WriteFloat((os.time() - BSU.UTCTime()) / 3600) -- UTC timezone offset (-12 to 14)
  net.SendToServer()
end