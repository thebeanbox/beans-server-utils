-- commands/player.lua

BSU:RegisterCommand({
    name = "god",
    aliases = { "build" },
    description = "Enters the player(s) into god mode (default player is self)",
    category = "player",
    exec = function(sender, args)
        local targets = BSU:GetPlayersByString(args[1]) or { sender }
        if #targets == 0 then return end

        for _, ply in ipairs(targets) do
            ply:GodEnable()
        end
        
        BSU:SendPlayerInfoMsg(sender, " entered god mode for ", targets)
    end
})

BSU:RegisterCommand({
    name = "ungod",
    aliases = { "pvp" },
    description = "Exits the player(s) from god mode (default player is self)",
    category = "player",
    exec = function(sender, args)
        local targets = BSU:GetPlayersByString(args[1]) or { sender }
        if #targets == 0 then return end

        for _, ply in ipairs(targets) do
            ply:GodDisable()
        end

        BSU:SendPlayerInfoMsg(sender, " exited god mode for ", targets)
    end
})

BSU:RegisterCommand({
    name = "kill",
    aliases = { "slay" },
    description = "Kills the player(s) (default player is self)",
    category = "player",
    hasPermission = function(sender)
        return BSU:PlayerIsStaff(sender)
    end,
    exec = function(sender, args)
        local targets = BSU:GetPlayersByString(args[1]) or { sender }
        if #targets == 0 then return end

        for _, ply in ipairs(targets) do
            ply:Kill()
        end

        BSU:SendPlayerInfoMsg(sender, " killed ", targets)
    end
})

BSU:RegisterCommand({
    name = "nameColor",
    aliases = { "uniqueColor" },
    description = "Sets the player(s) name color (default player is self)",
    category = "player",
    hasPermission = function(sender)
        return BSU:PlayerIsSuperAdmin(sender)
    end,
    exec = function(sender, args)
        local targets = BSU:GetPlayersByString(args[1]) or { sender }
        if #targets == 0 then return end

        local color
        if args[2] and args[2] ~= "" then
            if args[2] and args[3] and args[4] then -- it's probably rgb
                if tonumber(args[2]) and tonumber(args[3]) and tonumber(args[4]) then
                    color = Color(tonumber(args[2]), tonumber(args[3]), tonumber(args[4]))
                end
            end
            if not color and args[2] then -- failed to get rgb, try hex
                pcall(function()
                    color = BSU:HexToColor(args[2])
                end)
            end
            if not color then return end
        end
        
        for _, ply in ipairs(targets) do
            BSU:SetPlayerUniqueColor(ply, color or team.GetColor(ply:Team())) -- set or reset name color
        end

        BSU:SendPlayerInfoMsg(sender, " " .. (color and "set" or "removed") .. " the name color for ", targets)
    end
})
