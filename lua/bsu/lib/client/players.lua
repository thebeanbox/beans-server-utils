-- lib/client/players.lua

function BSU.SendClientInfo()
  net.Start("BSU_ClientInfo")
    net.WriteUInt(system.IsWindows() and 0 or system.IsLinux() and 1 or system.IsOSX() and 2, 2)
    net.WriteString(system.GetCountry())
    net.WriteInt((os.time() - BSU.UTCTime()) / 3600, 5)
  net.SendToServer()
end