if SERVER then
    BSU:RegisterCommand({
        name = "god",
        concmd = { "bsu god" },
        chat_commands = { "/build", "!build", "!god", "/god" }
        exec = function(ply, args, method) -- ply = player who initiated, args = the values the player passes after the base command, method = concmd or chat?
            if SERVER then
                ply:GodEnable()
                BSU:SendChatMessageToAll(ply:Nick() .. " has entered buildmode!")
            else   
            end
    })
    BSU:RegisterCommand({
        name = "ungod",
        concmd = { "bsu ungod" },
        chat_commands = { "/build", "!build", "!god", "/god" }
        exec = function(ply, args, method)
            if SERVER then
                ply:GodDisable()
                BSU:SendChatMessageToAll(ply:Nick() .. " has exited buildmode!")
            else
            end
    })
else
    
end
