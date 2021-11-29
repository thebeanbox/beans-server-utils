if SERVER then
	util.AddNetworkString("BSU_PlayerInfoMsg")

	function BSU:SendPlayerInfoMsg(sender, message, targets)
		net.Start("BSU_PlayerInfoMsg")
		    net.WriteEntity(sender)
            net.WriteString(message)
            for _, ply in ipairs(targets) do
                net.WriteEntity(ply)
            end
        net.Broadcast()
    end
else
    net.Receive("BSU_PlayerInfoMsg", function(len)
        local sender = net.ReadEntity()
        local message = net.ReadString()
        local targets = {}
        while true do
            local ply = net.ReadEntity()
            if ply:IsValid() then
                table.insert(targets, ply)
            else
                break
            end
        end
        
        local msgContent
        if LocalPlayer() == sender then
            msgContent = {
                bsuChat._color(Color(150, 0, 230)),
                bsuChat._bold(),
                bsuChat._text("You"),
                bsuChat._bold(false),
                bsuChat._color()
            }
        else
            msgContent = { bsuChat._player(sender) }
        end
        table.insert(msgContent, bsuChat._color(Color(151, 211, 255)))
        table.insert(msgContent, bsuChat._text(message))
        
        for k, ply in ipairs(targets) do -- get target name values
            local values
            if ply == sender then
                values = {
                    bsuChat._color(Color(150, 0, 230)),
                    bsuChat._bold(),
                    bsuChat._text(LocalPlayer() == sender and "Yourself" or "Themself"),
                    bsuChat._bold(false)
                }
            else
                values = { bsuChat._player(ply) }
            end

            for _, v in ipairs(values) do
                table.insert(msgContent, v)
            end

            if k ~= #targets then
                table.insert(msgContent, bsuChat._color(Color(151, 211, 255)))
                table.insert(msgContent, k < #targets - 1 and bsuChat._text(", ") or bsuChat._text(" and "))
            end
        end

        local msg = {} -- for console and normal chat messages
        for _, v in ipairs(msgContent) do -- only keeps color and text from the custom message
            if v.type == "text" then
                table.insert(msg, v.value)
            elseif v.type == "color" then
                table.insert(msg, v.value)
            elseif v.type == "hyperlink" then
                table.insert(msg, v.value.text or v.value.url)
            end
        end

        if bsuChat then -- custom message
            bsuChat.send(
                {
                    chatType = "info",
                    messageContent = msgContent
                }
            )
        else -- normal message
            chat.AddText(unpack(msg))
        end

        table.insert(msg, "\n")

        MsgC(unpack(msg))
    end)
end
