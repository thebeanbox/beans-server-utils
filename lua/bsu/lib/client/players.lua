-- lib/client/players.lua

function BSU.SendClientInfo()
  net.Start("BSU_ClientInfo")
    net.WriteString(system.IsWindows() and "Windows" or system.IsLinux() and "Linux" or system.IsOSX() and "macOS")
    net.WriteString(system.GetCountry())
    net.WriteInt((os.time() - BSU.UTCTime()) / 3600, 5)
  net.SendToServer()
end