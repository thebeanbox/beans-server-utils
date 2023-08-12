BSU.SetupCommand("nothing", function(cmd)
	cmd:SetDescription("Do nothing to players")
	cmd:SetFunction(function(self, _, targets)
		self:BroadcastActionMsg("%caller% did nothing to %targets%", { targets = targets })
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("afk", function(cmd)
	cmd:SetDescription("Set yourself as afk")
	cmd:SetSilent(true)
	cmd:SetFunction(function(_, caller, reason)
		caller.bsu_afk = true
		local msg = { caller, " is now AFK" }
		if reason then table.Add(msg, { " (", BSU.CLR_PARAM, reason, BSU.CLR_TEXT, ")" }) end
		BSU.SendChatMsg(nil, unpack(msg))
	end)
	cmd:SetValidCaller(true)
	cmd:AddStringArg("reason", { optional = true, multi = true })
end)

-- prevent gaining total time while afk
hook.Add("BSU_PlayerTotalTime", "BSU_PreventAFKTime", function(ply)
	if ply.bsu_afk then return false end
end)

-- make not afk if any key presses
hook.Add("KeyPress", "BSU_ClearAFK", function(ply)
	if ply.bsu_afk then
		ply.bsu_afk = nil
		BSU.SendChatMsg(nil, ply, " is no longer AFK")
	end
	ply.bsu_last_interacted_time = SysTime()
end)

-- make afk after some time with no key presses
timer.Create("BSU_CheckAFK", 1, 0, function()
	for _, ply in ipairs(player.GetHumans()) do
		if not ply.bsu_last_interacted_time or ply.bsu_afk then continue end
		if SysTime() > ply.bsu_last_interacted_time + 600 then
			BSU.SafeRunCommand(ply, "afk")
		end
	end
end)
