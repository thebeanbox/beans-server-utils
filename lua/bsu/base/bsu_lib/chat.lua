if SERVER then
	util.AddNetworkString("bsu_sendchatmessagetoall")
	function BSU:SendChatMessageToAll(data)
		net.Start("bsu_sendchatmessagetoall")
		net.WriteType(util.Compress(util.TableToJSON(data))
        	net.Broadcast()
    end
elseif CLIENT then
    net.Receive("bsu_sendchatmessagetoall", function(len)
        str = util.JSONToTable(util.Decompress(net.ReadData(len)))
        chat.AddText(Color(235, 179, 68), "[BSU]", Color(255, 174, 97), unpack(data))
    end)
end
