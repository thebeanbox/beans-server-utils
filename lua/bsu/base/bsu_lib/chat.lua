if SERVER then
	function BSU:SendChatMessageToAll(varargs ToSend)
		net.Start("bsu_sendchatmessagetoall")
		net.WriteType(ToSend)
        net.Broadcast()
    end
elseif CLIENT then
    net.Receive("bsu_sendchatmessagetoall", function()
        str = net.ReadTable()
        chat.AddText(Color(235, 179, 68) .. ["BSU"] .. Color(255, 174, 97))
    end)
end
