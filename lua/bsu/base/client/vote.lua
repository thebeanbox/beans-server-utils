BSU.ActiveVotes = {}

net.Receive("bsu_vote", function()
	local id = net.ReadString()
	if net.ReadBool() then
		local title = net.ReadString()
		local duration = net.ReadUInt(32)
		local author = net.ReadEntity()

		local optCount = net.ReadUInt(32)
		local options = {}
		for i = 1, optCount do
			options[i] = net.ReadString()
		end

		local vote = {
			id = id,
			title = title,
			duration = duration,
			author = author,
			options = options,
			players = {},
		}
		BSU.ActiveVotes[id] = vote

		hook.Run("BSU_VoteStart", vote)
		return
	end

	local vote = BSU.ActiveVotes[id]
	if not vote then return end
	BSU.ActiveVotes[id] = nil
	hook.Run("BSU_VoteEnd", vote)
end)

net.Receive("bsu_ply_vote", function()
	local ply = net.ReadEntity()
	local id = net.ReadString()
	local optionIndex = net.ReadUInt(32)

	local vote = BSU.ActiveVotes[id]
	if not vote then return end
	if optionIndex > #vote.options then return end

	vote.players[ply] = optionIndex

	hook.Run("BSU_PlayerVote", vote, ply, optionIndex)
end)

function BSU.VoteFor(vote, optionIndex)
	net.Start("bsu_ply_vote")
	net.WriteString(vote.id)
	net.WriteUInt(optionIndex, 32)
	net.SendToServer()

	hook.Run("BSU_PlayerVote", vote, LocalPlayer(), optionIndex)
end

