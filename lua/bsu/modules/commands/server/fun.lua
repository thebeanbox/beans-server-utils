local function getSpawnInfo(ply)
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

local function prevent(ply)
	if ply.bsu_ragdoll then return false end
end

hook.Add("PlayerSpawnObject", "BSU_Ragdoll", prevent)
hook.Add("PlayerSpawnSENT", "BSU_Ragdoll", prevent)
hook.Add("PlayerSpawnVehicle", "BSU_Ragdoll", prevent)
hook.Add("PlayerSpawnNPC", "BSU_Ragdoll", prevent)
hook.Add("CanPlayerSuicide", "BSU_Ragdoll", prevent)

hook.Add("PlayerSpawn", "BSU_Ragdoll", function(ply)
	if ply.bsu_ragdoll then
		timer.Simple(0, function()
			if not ply:IsValid() or not ply.bsu_ragdoll then return end
			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity(ply.bsu_ragdoll)
			ply:StripWeapons()
		end)
	end
end)

hook.Add("PlayerDisconnected", "BSU_Ragdoll", function(ply)
	if ply.bsu_ragdoll then
		ply.bsu_ragdoll:RemoveCallOnRemove("BSU_Ragdoll")
		ply.bsu_ragdoll:Remove()
	end
end)

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