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
	util.AddNetworkString("BSU_CommandMessage")

	function BSU:SendPlayerInfoMsg(ply, msgData)
        local nameColor, name = BSU:GetPlayerNameValues(ply)

		net.Start("BSU_CommandMessage")
		    net.WriteData(util.Compress(util.TableToJSON({ nameColor = nameColor, name = name, msgData = msgData})))
        net.Broadcast()
    end
else
    net.Receive("BSU_CommandMessage", function(len)
        local data = util.JSONToTable(util.Decompress(net.ReadData(len)))
        
        bsuChat.send(
            {
                messageContent = {
                    { -- set name color
                        type = "color",
                        value = data.nameColor
                    },
                    { -- make upcoming name bold
                        type = "bold",
                        value = true
                    },
                    { -- player name
                        type = "text",
                        value = data.name
                    },
                    { -- no longer bold
                        type = "bold",
                        value = false
                    },
                    { -- reset color
                        type = "color",
                        value = color_white
                    },
                    unpack(data.msgData)
                }
            }
        )

        local msg = ""
        for _, v in ipairs(data.msgData) do
            if v.type == "text" then
                msg = msg .. v.value
            end
        end

        MsgC(data.nameColor, data.name, color_white, msg, "\n")
    end)
end
