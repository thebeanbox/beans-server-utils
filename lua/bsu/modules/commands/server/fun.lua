local function getSpawnInfo(ply)
	if ply.bsu_spawnInfo then return end

	local data = {}
	data.health = ply:Health()
	data.armor = ply:Armor()

	local weps = {}
	for _, wep in ipairs(ply:GetWeapons()) do
		weps[wep:GetClass()] = {
			clip1 = wep:Clip1(),
			clip2 = wep:Clip2(),
			ammo1 = ply:GetAmmoCount(wep:GetPrimaryAmmoType()),
			ammo2 = ply:GetAmmoCount(wep:GetSecondaryAmmoType())
		}
	end

	data.weps = weps

	local active = ply:GetActiveWeapon()
	if IsValid(active) then data.activewep = active:GetClass() end

	ply.bsu_spawnInfo = data
end

local function setWeapons(ply, weps, active)
	ply:StripAmmo()
	ply:StripWeapons()

	for class, data in pairs(weps) do
		local wep = ply:Give(class)
		if wep:IsValid() then
			wep:SetClip1(data.clip1)
			wep:SetClip2(data.clip2)
			ply:SetAmmo(data.ammo1, wep:GetPrimaryAmmoType())
			ply:SetAmmo(data.ammo2, wep:GetSecondaryAmmoType())
		end
	end

	if active then ply:SelectWeapon(active) end
end

local function doSpawn(ply)
	ply:Spawn()
	local data = ply.bsu_spawnInfo
	if data then
		ply:SetHealth(data.health)
		ply:SetArmor(data.armor)
		timer.Simple(0, function() if ply:IsValid() then setWeapons(ply, data.weps, data.activewep) end end)
		ply.bsu_spawnInfo = nil
	end
end

local function ragdollPlayer(ply, owner)
	if IsValid(ply.bsu_ragdoll) then return false end

	local ragdoll = ents.Create("prop_ragdoll")
	if not IsValid(ragdoll) then return false end

	BSU.SetEntityOwner(ragdoll, owner:IsValid() and owner or game.GetWorld())
	duplicator.DoGeneric(ragdoll, duplicator.CopyEntTable(ply))

	ragdoll:Spawn()
	ragdoll:Activate()
	ragdoll:CallOnRemove("BSU_Ragdoll", function()
		if ply:IsValid() then
			ply.bsu_ragdoll = nil
			ragdollPlayer(ply, owner)
		end
	end)

	local vel = ply:GetVelocity()

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local physobj = ragdoll:GetPhysicsObjectNum(i)
		if IsValid(physobj) then
			local boneid = ragdoll:TranslatePhysBoneToBone(i)
			local matrix = ply:GetBoneMatrix(boneid)
			physobj:SetPos(matrix:GetTranslation())
			physobj:SetAngles(matrix:GetAngles())
			physobj:AddVelocity(vel)
		end
	end

	if ply:InVehicle() then ply:ExitVehicle() end

	getSpawnInfo(ply)

	ply.bsu_ragdoll = ragdoll
	ply:SetParent(ragdoll)
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(ragdoll)
	ply:StripWeapons()

	return true
end

local function unragdollPlayer(ply)
	if not IsValid(ply.bsu_ragdoll) then return false end

	local oldPos = ply:GetPos()
	local oldAngles = ply:EyeAngles()
	ply:SetParent()
	ply:UnSpectate()
	doSpawn(ply)
	ply:SetPos(oldPos)
	ply:SetEyeAngles(oldAngles)
	ply:SetVelocity(ply.bsu_ragdoll:GetVelocity())

	ply.bsu_ragdoll:RemoveCallOnRemove("BSU_Ragdoll")
	ply.bsu_ragdoll:Remove()
	ply.bsu_ragdoll = nil

	return true
end

hook.Add("PlayerSpawn", "BSU_FixRagdollSpawn", function(ply)
	if ply.bsu_ragdoll then
		timer.Simple(0, function()
			if not ply:IsValid() or not ply.bsu_ragdoll then return end
			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity(ply.bsu_ragdoll)
			ply:StripWeapons()
		end)
	end
end)

hook.Add("PlayerDisconnected", "BSU_RemoveRagdoll", function(ply)
	if ply.bsu_ragdoll then
		ply.bsu_ragdoll:RemoveCallOnRemove("BSU_Ragdoll")
		ply.bsu_ragdoll:Remove()
	end
end)


local function block(ply)
	if ply.bsu_ragdoll or ply.bsu_frozen then return false end
end

hook.Add("PlayerSpawnObject", "BSU_BlockPlayer", block)
hook.Add("PlayerSpawnSENT", "BSU_BlockPlayer", block)
hook.Add("PlayerSpawnVehicle", "BSU_BlockPlayer", block)
hook.Add("PlayerSpawnNPC", "BSU_BlockPlayer", block)
hook.Add("CanPlayerSuicide", "BSU_BlockPlayer", block)

--[[
	Name: ragdoll
	Desc: Set players into ragdoll mode
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("ragdoll", function(cmd)
	cmd:SetDescription("Set players into ragdoll mode")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		local ragdolled = {}
		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) and ragdollPlayer(v, self:GetCaller()) then -- successfully ragdolled
				self:SetExclusive(v, "ragdolled")
				table.insert(ragdolled, v)
			end
		end

		if next(ragdolled) ~= nil then
			self:BroadcastActionMsg("%caller% ragdolled %ragdolled%", { ragdolled = ragdolled })
		end
	end)
end)

--[[
	Name: unragdoll
	Desc: Set players out of ragdoll mode
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("unragdoll", function(cmd)
	cmd:SetDescription("Set players out of ragdoll mode")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		local unragdolled = {}
		for _, v in ipairs(targets) do
			if unragdollPlayer(v) then -- successfully unragdolled
				self:ClearExclusive(v)
				table.insert(unragdolled, v)
			end
		end

		if next(unragdolled) ~= nil then
			self:BroadcastActionMsg("%caller% unragdolled %unragdolled%", { unragdolled = unragdolled })
		end
	end)
end)

--[[
	Name: freeze
	Desc: Make players unable to move
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("freeze", function(cmd)
	cmd:SetDescription("Make players unable to move")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		local frozen = {}
		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) then
				v:Lock()
				v.bsu_frozen = true
				self:SetExclusive(v, "frozen")
				table.insert(frozen, v)
			end
		end

		if next(frozen) ~= nil then
			self:BroadcastActionMsg("%caller% froze %frozen%", { frozen = frozen })
		end
	end)
end)

--[[
	Name: unfreeze
	Desc: Make players able to move again
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("unfreeze", function(cmd)
	cmd:SetDescription("Make players able to move again")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetPlayersArg(1)
		if targets then
			targets = self:FilterTargets(targets, nil, true)
		else
			targets = { self:GetCaller(true) }
		end

		local unfrozen = {}
		for _, v in ipairs(targets) do
			if v:IsFlagSet(FL_FROZEN) then
				v:UnLock()
				v.bsu_frozen = nil
				self:ClearExclusive(v)
				table.insert(unfrozen, v)
			end
		end

		if next(unfrozen) ~= nil then
			self:BroadcastActionMsg("%caller% froze %unfrozen%", { unfrozen = unfrozen })
		end
	end)
end)

--[[
	Name: health
	Desc: Set health of players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("health", function(cmd)
	cmd:SetDescription("Set health of players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetPlayersArg(1)
		local amount
		if targets then
			targets = self:FilterTargets(targets, nil, true)
			amount = self:GetNumberArg(2, true)
		else
			targets = { self:GetCaller(true) }
			amount = self:GetNumberArg(1, true)
		end

		amount = math.min(math.max(amount, 0), 2 ^ 31 - 1)

		for _, v in ipairs(targets) do
			v:SetHealth(amount)
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% set the health of %targets% to %amount%", { targets = targets, amount = amount })
		end
	end)
end)
BSU.AliasCommand("hp", "health")

--[[
	Name: armor
	Desc: Set armor of players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("armor", function(cmd)
	cmd:SetDescription("Set armor of players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetPlayersArg(1)
		local amount
		if targets then
			targets = self:FilterTargets(targets, nil, true)
			amount = self:GetNumberArg(2, true)
		else
			targets = { self:GetCaller(true) }
			amount = self:GetNumberArg(1, true)
		end

		amount = math.min(math.max(amount, 0), 2 ^ 31 - 1)

		for _, v in ipairs(targets) do
			v:SetArmor(amount)
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% set the armor of %targets% to %amount%", { targets = targets, amount = amount })
		end
	end)
end)
BSU.AliasCommand("suit", "armor")