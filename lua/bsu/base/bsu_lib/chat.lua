function BSU:GetPlayerNameValues(ply)
    local nameColor, name
    if ply and ply:IsValid() then
        name = ply:Nick()
        nameColor = BSU:PlayerGetColor(ply)
    else
        name = "Console"
        nameColor = Color(151, 211, 255)
    end

    return nameColor, name
end

if SERVER then
	util.AddNetworkString("BSU_CommandMessage")

	function BSU:SendCommandMsg()
		net.Start("BSU_CommandMessage")
		    net.WriteData(util.Compress(util.TableToJSON({...}))
        net.Broadcast()
    end
elseif CLIENT then
    net.Receive("BSU_CommandMessage", function(len)
        local args = util.JSONToTable(util.Decompress(net.ReadData(len)))
        chat.AddText(unpack(args))
    end)
end
