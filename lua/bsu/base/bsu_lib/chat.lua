function BSU:GetPlayerNameValues(ply)
    local nameColor, name
    if ply and ply:IsValid() then
        name = ply:Nick()
        nameColor = BSU:GetPlayerColor(ply)
    else
        name = "Console"
        nameColor = Color(151, 211, 255)
    end

    return nameColor, name
end

if SERVER then
	util.AddNetworkString("BSU_PlayerInfoMessage")

	function BSU:SendPlayerInfoMsg(ply, msgData)
        local nameColor, name = BSU:GetPlayerNameValues(ply)

		net.Start("BSU_PlayerInfoMessage")
		    net.WriteData(util.Compress(util.TableToJSON({ nameColor = nameColor, name = name, msgData = msgData})))
        net.Broadcast()
    end
else
    net.Receive("BSU_PlayerInfoMessage", function(len)
        local data = util.JSONToTable(util.Decompress(net.ReadData(len)))
        
        local msg = ""
        for _, v in ipairs(data.msgData) do
            if v.type == "text" then
                msg = msg .. v.value
            elseif v.type == "hyperlink" then
                msg = msg .. v.value.url
            end
        end

        if bsuChat then -- custom bsuChat message
            bsuChat.send(
                {
                    chatType = "info",
                    messageContent = {
                        bsuChat._color(data.nameColor), -- set name color
                        bsuChat._bold(), -- make upcoming name bold
                        bsuChat._text(data.name), -- player name
                        bsuChat._bold(false), -- no longer bold
                        bsuChat._color(), -- reset color
                        unpack(data.msgData)
                    }
                }
            )
        else -- normal message
            chat.AddText(data.nameColor, data.name, color_white, msg)
        end

        MsgC(data.nameColor, data.name, color_white, msg, "\n")
    end)
end
