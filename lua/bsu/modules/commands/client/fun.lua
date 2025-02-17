local function setRagdollColor(ent, clr)
	function ent:GetPlayerColor()
		return clr
	end
end

local ragdollColorQueue = {}

hook.Add("OnEntityCreated", "BSU_RagdollCommandColor", function(ent)
	local ind = ent:EntIndex()
	local clr = ragdollColorQueue[ind]
	if not clr then return end

	setRagdollColor(ent, clr)
	ragdollColorQueue[ind] = nil
end)

net.Receive("bsu_ragdoll_color", function()
	local ind = net.ReadUInt(13)
	local clr = net.ReadVector()

	-- in case the ragdoll entity somehow made it to the client already
	-- might not be needed
	local ragdoll = Entity(ind)
	if ragdoll:IsValid() then
		setRagdollColor(ragdoll, clr)
		return
	end

	ragdollColorQueue[ind] = clr
end)
