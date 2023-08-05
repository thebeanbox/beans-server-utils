BSU.CurrentVote = nil
local optionVotes = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}


local function getTotalVotes()
	if not BSU.CurrentVote then return end
	return table.Count(BSU.CurrentVote.votes)
end

-- Updates the `optionVotes` table where the index is the option and the value is number of votes
local function countOptionVotes()
	if not BSU.CurrentVote then return end
	optionVotes = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	for _, v in pairs(BSU.CurrentVote.votes) do
		optionVotes[v] = optionVotes[v] + 1
	end
end


if SERVER then
	util.AddNetworkString("bsu_vote")
	util.AddNetworkString("bsu_updateVote")

	local function updateClientVotes()
		net.Start("bsu_updateVote")
		net.WriteTable(BSU.CurrentVote.votes)		-- CHANGE!!!
		net.Broadcast()
	end

	net.Receive("bsu_updateVote", function()
		if not BSU.CurrentVote then return end
		if not BSU.CurrentVote.isActive then return end

		BSU.CurrentVote.votes = net.ReadTable()			-- CHANGE!!!
		updateClientVotes()
	end)

	-- Broadcasts voting table to the clients to sync up
	-- Will write the BSU.CurrentVote table's elements if the vote currently exists
	-- Will write nothing if there is no vote happening
	local function broadcastVote()
		net.Start("bsu_vote")
		if BSU.CurrentVote then
			net.WriteBool(true) -- Yes, there is a vote going on!
			net.WriteString(BSU.CurrentVote.author)
			net.WriteString(BSU.CurrentVote.title)
			net.WriteFloat(BSU.CurrentVote.timeStarted)
			net.WriteFloat(BSU.CurrentVote.duration)
			net.WriteTable(BSU.CurrentVote.options)		-- CHANGE!!!
			net.WriteTable(BSU.CurrentVote.votes)		-- CHANGE!!!
			net.WriteBool(BSU.CurrentVote.isActive)
		else
			net.WriteBool(false) -- No, there isn't a vote going on
		end

		net.Broadcast()
	end

	-- End the current vote (if it exists)
	local function endVote()
		if not BSU.CurrentVote then error("There is no vote in progress!") end

		BSU.CurrentVote = nil
		broadcastVote()
	end

	-- Start a new vote (if there isn't one in progress)
	function BSU.StartVote(ply, title, duration, options, endFunc)
		BSU.CurrentVote = {
			author = ply:IsValid() and ply:Nick() or "Console",
			title = title,
			timeStarted = os.time(),
			duration = duration,
			options = options,
			votes = {},
			isActive = true,
		}

		broadcastVote()

		timer.Create("bsu_votefinished", duration, 1, function()
			countOptionVotes()
			endFunc(BSU.CurrentVote)
			endVote()
		end)
	end

	BSU.SetupCommand("vote", function(cmd)
		cmd:SetDescription("Starts a vote")
		cmd:SetAccess(BSU.CMD_ADMIN)
		cmd:SetFunction(function(self)
			if BSU.CurrentVote then error("There is already a vote in progress!") end

			local title = self:GetStringArg(1, true)
			local options = {}

			-- Populate options table starting at argument 2
			for i = 2, 11 do
				local option = self:GetStringArg(i)
				if not option then break end
				table.insert(options, option)
			end

			self:BroadcastActionMsg("%caller% started a vote \"%title%\"", {title = title})

			BSU.StartVote(self:GetCaller(), title, 60, options, function(vote)
				local winnerIndex = 0
				local highestVoteCount = 0
				for k, v in ipairs(optionVotes) do
					if v > highestVoteCount then winnerIndex = k end
				end
				local winner = vote.options[winnerIndex]
				self:BroadcastActionMsg("The vote has ended! The winner is \"%winner%\"", {winner = winner})
			end)
		end)
	end)

else

	local voteBackgroundColor = Color(0, 0, 0, 200)
	local voteTextColor = Color(255, 255, 255)
	local currentTotalVotes = 0
	local currentVote = 0
	local lastVoted = 0

	surface.CreateFont("VoteTitle", {
		font = "Arial",
		extended = true,
		size = 25,
		weight = 700,
		antialias = false,
		shadow = true,
	})

	surface.CreateFont("VoteAuthor", {
		font = "Arial",
		extended = true,
		size = 20,
		weight = 600,
		antialias = false,
		shadow = true,
	})

	surface.CreateFont("VoteContent", {
		font = "Arial",
		extended = true,
		size = 15,
		weight = 600,
		antialias = false,
		shadow = true,
	})

	local function updateServerVotes()
		net.Start("bsu_updateVote")
		net.WriteTable(BSU.CurrentVote.votes)	-- CHANGE!!!
		net.SendToServer()
	end

	-- Vote on option `n` if it exists, then tell the server you did it
	local function makeVote(n)
		if not BSU.CurrentVote then return end				-- No vote exists?
		if not BSU.CurrentVote.isActive then return end		-- Vote no longer accepting input?

		if not BSU.CurrentVote.options[n] then return end		-- Vote option doesn't exist?
		BSU.CurrentVote.votes[LocalPlayer()] = n
		lastVoted = os.time()

		updateServerVotes()
	end


	net.Receive("bsu_vote", function()
		local isVoteActive = net.ReadBool()

		if not isVoteActive then
			print("There is nothing")
			BSU.CurrentVote.isActive = false
			timer.Create("stopshowing", 10, 1, function()
				BSU.CurrentVote = nil
			end)
			return
		end

		local author = net.ReadString()
		local title = net.ReadString()
		local timeStarted = net.ReadFloat()
		local duration = net.ReadFloat()
		local options = net.ReadTable()			-- CHANGE!!!
		local votes = net.ReadTable()			-- CHANGE!!!
		local isActive = net.ReadBool()

		BSU.CurrentVote = {
			author = author,
			title = title,
			timeStarted = timeStarted,
			duration = duration,
			options = options,
			votes = votes,
			isActive = isActive,
		}

		currentTotalVotes = getTotalVotes()
		countOptionVotes()
		currentVote = 0
	end)

	net.Receive("bsu_updateVote", function()
		BSU.CurrentVote.votes = net.ReadTable()	-- CHANGE!!!
		currentTotalVotes = getTotalVotes()
		countOptionVotes()
	end)


	hook.Add("HUDPaint", "BeanBox_VoteHUDPaint", function()
		if not BSU.CurrentVote then return end

		surface.SetFont("VoteTitle")
		local titleW, _ = surface.GetTextSize(BSU.CurrentVote.title)

		local scrW, scrH = ScrW(), ScrH()
		local voteW, voteH = math.max(scrW * 0.1, titleW + 20), math.max(scrH * 0.25, 50 + #BSU.CurrentVote.options * 38)
		local voteX, voteY = 10, scrH / 2 - voteH / 2
		-- MY DOG'S ANGRY!!!!!!!!!!! >:(
		draw.RoundedBox(10, voteX, voteY, voteW, voteH, voteBackgroundColor)
		draw.SimpleText(BSU.CurrentVote.title, "VoteTitle", voteX + 10, voteY + 10, voteTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("By: " .. BSU.CurrentVote.author, "VoteAuthor", voteX + 10, voteY + 35, voteTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		for k, v in ipairs(BSU.CurrentVote.options) do
			local optX, optY = voteX + 10, voteY + 25 + k * 35
			local votePercent = optionVotes[k] / currentTotalVotes
			draw.SimpleText(tostring(k) .. ") " .. v, "VoteContent", optX, optY, voteTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			surface.SetDrawColor(186, 47, 47)
			surface.DrawRect(optX, optY + 20, voteW - 50, 10)
			surface.SetDrawColor(54, 154, 247)
			surface.DrawRect(optX, optY + 20, (voteW - 50) * votePercent, 10)
			draw.SimpleText(tostring(optionVotes[k]), "VoteContent", optX + voteW - 40, optY + 18, voteTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			-- Highlight your option
			if currentVote ~= k then continue end
			surface.SetDrawColor(255, 150, 0)
			surface.DrawOutlinedRect(optX - 5, optY - 2, voteW - 15, 37, 2)
		end
	end)

	hook.Add("CreateMove", "BeanBox_GatherInput", function()
		if not BSU.CurrentVote then return end
		if not BSU.CurrentVote.isActive then return end
		print(os.time(), lastVoted + 5)
		if os.time() < lastVoted + 5 then return end		-- Is under cooldown?

		if input.WasKeyPressed(KEY_1) then
			currentVote = 1
			makeVote(currentVote)
		elseif input.WasKeyPressed(KEY_2) then
			currentVote = 2
			makeVote(currentVote)
		elseif input.WasKeyPressed(KEY_3) then
			currentVote = 3
			makeVote(currentVote)
		elseif input.WasKeyPressed(KEY_4) then
			currentVote = 4
			makeVote(currentVote)
		elseif input.WasKeyPressed(KEY_5) then
			currentVote = 5
			makeVote(currentVote)
		elseif input.WasKeyPressed(KEY_6) then
			currentVote = 6
			makeVote(currentVote)
		elseif input.WasKeyPressed(KEY_7) then
			currentVote = 7
			makeVote(currentVote)
		elseif input.WasKeyPressed(KEY_8) then
			currentVote = 8
			makeVote(currentVote)
		elseif input.WasKeyPressed(KEY_9) then
			currentVote = 9
			makeVote(currentVote)
		elseif input.WasKeyPressed(KEY_0) then
			currentVote = 10
			makeVote(currentVote)
		end
	end)

end