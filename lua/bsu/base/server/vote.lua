util.AddNetworkString("bsu_vote")
util.AddNetworkString("bsu_ply_vote")

BSU.ActiveVotes = {}

net.Receive("bsu_ply_vote", function(_, ply)
	local id = net.ReadString()
	local optionIndex = net.ReadUInt(32)

	local vote = BSU.ActiveVotes[id]
	if not vote then return end
	if optionIndex > #vote.options then return end

	vote.players[ply] = optionIndex

	hook.Run("BSU_PlayerVote", vote, ply, optionIndex)

	net.Start("bsu_ply_vote")
	net.WriteEntity(ply)
	net.WriteString(id)
	net.WriteUInt(optionIndex, 32)
	net.SendOmit(ply)
end)

function BSU.StartVote(title, duration, author, options, callback)
	local vote = {
		title = title,
		start = CurTime(),
		duration = duration,
		author = author,
		options = options,
		players = {},
		callback = callback,
	}
	vote.id = string.format("%p", vote)

	net.Start("bsu_vote")
	net.WriteString(vote.id)
	net.WriteBool(true)
	net.WriteString(vote.title)
	net.WriteUInt(vote.start, 32)
	net.WriteUInt(vote.duration, 32)
	net.WriteEntity(vote.author)

	net.WriteUInt(#vote.options, 32)
	for _, opt in ipairs(vote.options) do
		net.WriteString(opt)
	end
	net.Broadcast()

	BSU.ActiveVotes[vote.id] = vote
	hook.Run("BSU_VoteStart", vote)
	timer.Simple(duration, function()
		BSU.StopVote(vote)
		if callback then callback(vote.winner) end
	end)

	return vote
end

function BSU.StopVote(vote)
	if not BSU.ActiveVotes[vote.id] then return end

	net.Start("bsu_vote")
	net.WriteString(vote.id)
	net.WriteBool(false)
	net.Broadcast()

	BSU.ActiveVotes[vote.id] = nil

	vote.winner = BSU.TallyVote(vote)

	hook.Run("BSU_VoteEnd", vote)
end

function BSU.TallyVote(vote)
	if #vote.options == 0 then return end
	if not next(vote.players) then return false end

	local tally = {}
	for i in ipairs(vote.options) do
		tally[i] = {
			index = i,
			count = 0,
		}
	end

	for _, optionIndex in pairs(vote.players) do
		local tbl = tally[optionIndex]
		tbl.count = tbl.count + 1
	end

	table.sort(tally, function(a, b) return a.count > b.count end)

	return vote.options[tally[1].index]
end

function BSU.HasActiveVote(author)
	for _, vote in pairs(BSU.ActiveVotes) do
		if vote.author == author then return true end
	end
	return false
end

hook.Add("BSU_ClientReady", "BSU_NetworkVotes", function(ply)
	for _, vote in pairs(BSU.ActiveVotes) do
		net.Start("bsu_vote")
		net.WriteString(vote.id)
		net.WriteBool(true)
		net.WriteString(vote.title)
		net.WriteUInt(vote.start, 32)
		net.WriteUInt(vote.duration, 32)
		net.WriteEntity(vote.author)

		net.WriteUInt(#vote.options, 32)
		for _, opt in ipairs(vote.options) do
			net.WriteString(opt)
		end
		net.Send(ply)
	end
end)

