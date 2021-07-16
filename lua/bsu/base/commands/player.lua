if SERVER then
    BSU:RegisterCommand({
        name = "god",
        aliases = { "build" },
        description = "Enters the target(s) into god mode (they cannot receive damage or inflict damage on players)",
        usage = "[<players, defaults to self>]",
        category = "player",
        exec = function(ply, args)
            ply:GodEnable()
            BSU:SendCommandMsg(BSU:GetPlayerNameValues(ply), color_white, " has entered god mode")
        end
    })

    BSU:RegisterCommand({
        name = "ungod",
        aliases = { "pvp" },
        description = "Exits the target(s) from god mode (they can now receive damage or inflict damage on players again)",
        usage = "[<players, defaults to self>]",
        category = "player",
        exec = function(ply, args)
            ply:GodDisable()
            BSU:SendCommandMsg(BSU:GetPlayerNameValues(ply), color_white, " has exited god mode")
        end
    })

    BSU:RegisterCommand({
        name = "nameColor",
        aliases = { "uniqueColor" },
        description = "Sets the target(s) a unique name color (not supplying the color argument will take away the unique name color if they have it)",
        usage = "[<players, defaults to self>] [<color>]",
        category = "player",
        exec = function(ply, args)
            --BSU:SetPlayerUniqueColor(ply, args.color)
            BSU:SendCommandMsg(BSU:GetPlayerNameValues(ply), color_white, " set the name color of ", args.targets)
        end
    })
else
    
end
