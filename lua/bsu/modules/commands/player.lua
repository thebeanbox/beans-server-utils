-- commands/player.lua by Bonyoze

BSU:RegisterCommand({
    name = "god",
    aliases = { "build" },
    description = "Enters the target(s) into god mode (they cannot receive damage or inflict damage on players)",
    usage = "[<players, defaults to self>]",
    category = "player",
    exec = function(ply, args)
        ply:GodEnable()

        BSU:SendPlayerInfoMsg(ply, { bsuChat._text(" entered god mode for themself") })
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
        
        BSU:SendPlayerInfoMsg(ply, { bsuChat._text(" exited god mode for themself") })
    end
})

BSU:RegisterCommand({
    name = "nameColor",
    aliases = { "uniqueColor" },
    description = "Sets the target(s) a unique name color (not supplying the color argument will take away the unique name color if they have it)",
    usage = "[<players, defaults to self>] [<color>]",
    category = "player",
    hasPermission = function(ply)
        return BSU:PlayerIsSuperAdmin()
    end,
    exec = function(ply, args)
        --BSU:SetPlayerUniqueColor(ply, args.color)

    end
})