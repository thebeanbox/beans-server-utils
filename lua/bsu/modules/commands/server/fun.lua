hook.Add("PlayerSpawn", "BSU_FixGodRespawn", function(ply)
	if ply.bsu_godded then ply:AddFlags(FL_GODMODE) end
end)

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
		timer.Simple(0, function()
			if ply:IsValid() and not IsValid(ply.bsu_ragdoll) then
				setWeapons(ply, data.weps, data.activewep)
			end
		end)
		ply.bsu_spawnInfo = nil
	end
end

local function ragdollPlayer(ply, owner)
	if IsValid(ply.bsu_ragdoll) then return false end

	local ragdoll = ents.Create("prop_ragdoll")
	if not IsValid(ragdoll) then return false end

	BSU.SetOwner(ragdoll, owner:IsValid() and owner or game.GetWorld())
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

hook.Add("PlayerSpawn", "BSU_FixRagdollRespawn", function(ply)
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
	Name: god
	Desc: Enable godmode on players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("god", function(cmd)
	cmd:SetDescription("Enables godmode on a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		local godded = {}
		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) and not v.bsu_godded then
				v:AddFlags(FL_GODMODE)
				v.bsu_godded = true
				table.insert(godded, v)
			end
		end

		if next(godded) ~= nil then
			self:BroadcastActionMsg("%caller% godded %godded%", { godded = godded })
		end
	end)
end)
BSU.AliasCommand("build", "god")

--[[
	Name: ungod
	Desc: Disable godmode on players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("ungod", function(cmd)
	cmd:SetDescription("Enables godmode on a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		local ungodded = {}
		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) and v.bsu_godded then
				if not v.bsu_frozen then v:RemoveFlags(FL_GODMODE) end
				v.bsu_godded = nil
				table.insert(ungodded, v)
			end
		end

		if next(ungodded) ~= nil then
			self:BroadcastActionMsg("%caller% ungodded %ungodded%", { ungodded = ungodded })
		end
	end)
end)
BSU.AliasCommand("pvp", "ungod")

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
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

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
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

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
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		local frozen = {}
		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) then
				v:AddFlags(FL_FROZEN + FL_GODMODE)
				v:SetMoveType(MOVETYPE_NONE)
				v:SetVelocity(-v:GetVelocity())
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
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		local unfrozen = {}
		for _, v in ipairs(targets) do
			if v:IsFlagSet(FL_FROZEN) then
				v:RemoveFlags(FL_FROZEN)
				if not v.bsu_godded then v:RemoveFlags(FL_GODMODE) end
				v:SetMoveType(MOVETYPE_WALK)
				v.bsu_frozen = nil
				self:ClearExclusive(v)
				table.insert(unfrozen, v)
			end
		end

		if next(unfrozen) ~= nil then
			self:BroadcastActionMsg("%caller% unfroze %unfrozen%", { unfrozen = unfrozen })
		end
	end)
end)
BSU.AliasCommand("thaw", "unfreeze")

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
		local targets = self:GetRawStringArg(2) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }
		local amount = self:GetRawStringArg(2) and self:GetNumberArg(2, true) or self:GetNumberArg(1, true)

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
		local targets = self:GetRawStringArg(2) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }
		local amount = self:GetRawStringArg(2) and self:GetNumberArg(2, true) or self:GetNumberArg(1, true)

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

--[[
	Name: launch
	Desc: Launch players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("launch", function(cmd)
	cmd:SetDescription("Launch players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		for _, v in ipairs(targets) do
			v:SetVelocity(Vector(0, 0, 5000))
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% launched %targets%", { targets = targets })
		end
	end)
end)

--[[
	Name: respawn
	Desc: Respawn players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("respawn", function(cmd)
	cmd:SetDescription("Respawn players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		for _, v in ipairs(targets) do
			v:Spawn()
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% respawned %targets%", { targets = targets })
		end
	end)
end)

--[[
	Name: slay
	Desc: Slay players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("slay", function(cmd)
	cmd:SetDescription("Slay players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		for _, v in ipairs(targets) do
			v:Kill()
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% slayed %targets%", { targets = targets })
		end
	end)
end)
BSU.AliasCommand("kill", "slay")

--[[
	Name: disintegrate
	Desc: Disintegrate players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("disintegrate", function(cmd)
	cmd:SetDescription("Disintegrate players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		local dmgInfo = DamageInfo()
		dmgInfo:SetDamageType(DMG_DISSOLVE)

		for _, v in ipairs(targets) do
			dmgInfo:SetDamage(v:Health())
			dmgInfo:SetAttacker(v)
			v:GodDisable()
			v:TakeDamageInfo(dmgInfo)
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% disintegrated %targets%", { targets = targets })
		end
	end)
end)
BSU.AliasCommand("smite", "disintegrate")

--[[
	Name: explode
	Desc: Explode players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("explode", function(cmd)
	cmd:SetDescription("Explode players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		local dmgInfo = DamageInfo()
		dmgInfo:SetDamageType(DMG_BLAST)
		dmgInfo:SetDamage(1)

		for _, v in ipairs(targets) do
			local explosion = ents.Create("env_explosion")
			explosion:SetPos(v:GetPos())
			explosion:Spawn()

			explosion:Fire("Explode")
			explosion:EmitSound("BaseExplosionEffect.Sound", SNDLVL_GUNFIRE)

			v:GodDisable()
			v:SetHealth(0)
			v:SetArmor(0)

			dmgInfo:SetAttacker(v)
			v:TakeDamageInfo(dmgInfo)
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% exploded %targets%", { targets = targets })
		end
	end)
end)

--[[
	Name: enter
	Desc: Force a player into the vehicle you're looking at
	Arguments:
		1. Target (player, default: self)
]]
BSU.SetupCommand("enter", function(cmd)
	cmd:SetDescription("Force a player into the vehicle you're looking at")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local target = self:GetRawStringArg(1) and self:GetPlayerArg(1, true) or self:GetCaller(true)

		if not target:InVehicle() then
			local vehicle = self:GetCaller(true):GetEyeTrace().Entity
			if not vehicle:IsVehicle() then return end
			target:EnterVehicle(vehicle)
		end

		self:BroadcastActionMsg("%caller% forced %target% into a vehicle", { target = target })
	end)
end)

--[[
	Name: eject
	Desc: Eject players from the vehicle they're in
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("eject", function(cmd)
	cmd:SetDescription("Eject players from the vehicle they're in")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		local ejected = {}
		for _, v in ipairs(targets) do
			if v:InVehicle() then
				v:ExitVehicle()
				table.insert(ejected, v)
			end
		end

		if next(ejected) ~= nil then
			self:BroadcastActionMsg("%caller% ejected %ejected%", { ejected = ejected })
		end
	end)
end)

--[[
	Name: notification
	Desc: Send a notification to players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("notification", function(cmd)
	cmd:SetDescription("Send a notification to players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }
		local msg = self:GetMultiStringArg(2, -1, true)

		BSU.ClientRPC(targets, "notification.AddLegacy", msg, NOTIFY_GENERIC, 5)
		BSU.ClientRPC(targets, "surface.PlaySound", "buttons/button15.wav")
	end)
end)
BSU.AliasCommand("notify", "notification")

--[[
	Name: earthquake
	Desc: Shake the ground for players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("earthquake", function(cmd)
	cmd:SetDescription("Shake the ground for players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }
		local duration = math.min(math.max(self:GetNumberArg(2) or 10, 1), 10)

		BSU.ClientRPC(targets, "util.ScreenShake", Vector(), 100, 100, duration, 0)

		self:BroadcastActionMsg("%caller% shook the ground for %targets% for %duration% seconds.", { targets = targets, duration = duration })
	end)
end)
BSU.AliasCommand("shake", "earthquake")

local function collideOnlyPlayers(_, ent1, ent2)
	if not ent1:IsPlayer() and not ent2:IsPlayer() then return false end
end

--[[
	Name: bathe
	Desc: Throw a bathtub at players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("bathe", function(cmd)
	cmd:SetDescription("Throw a bathtub at players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		for _, v in ipairs(targets) do
			if not v.bsu_frozen then v:RemoveFlags(FL_GODMODE) end
			if v:InVehicle() then v:ExitVehicle() end
			if v:GetMoveType() == MOVETYPE_NOCLIP then v:SetMoveType(MOVETYPE_WALK) end

			local bath = ents.Create("prop_physics")
			BSU.SetOwnerWorld(bath)
			bath:SetModel("models/props_interiors/BathTub01a.mdl")
			bath:SetAngles(Angle(0, 180, 0))
			bath:SetPos(v:GetPos() + Vector(750, 0, 50))

			hook.Add("ShouldCollide", bath, collideOnlyPlayers)
			bath:SetCustomCollisionCheck(true)
			bath:Spawn()

			bath:GetPhysicsObject():EnableGravity(false)
			bath:GetPhysicsObject():SetMass(50000)
			bath:GetPhysicsObject():SetVelocity(Vector(-100000, 0, 0))
			bath:EmitSound("Physics.WaterSplash", 130, 100, 1, 0, 0)

			timer.Simple(3, function() if bath:IsValid() then bath:Remove() end end)
		end

		self:BroadcastActionMsg("%caller% bathed %targets%", { targets = targets })
	end)
end)

--[[
	Name: trainwreck
	Desc: Throw a train at players
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("trainwreck", function(cmd)
	cmd:SetDescription("Throw a train at players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		for _, v in ipairs(targets) do
			if not v.bsu_frozen then v:RemoveFlags(FL_GODMODE) end
			if v:InVehicle() then v:ExitVehicle() end
			if v:GetMoveType() == MOVETYPE_NOCLIP then v:SetMoveType(MOVETYPE_WALK) end

			local train = ents.Create("prop_physics")
			BSU.SetOwnerWorld(train)
			train:SetModel("models/props_trainstation/train001.mdl")
			train:SetAngles(Angle(0, 90, 0))
			train:SetPos(v:GetPos() + Vector(750, 0, 150))

			hook.Add("ShouldCollide", train, collideOnlyPlayers)
			train:SetCustomCollisionCheck(true)
			train:Spawn()

			train:GetPhysicsObject():EnableGravity(false)
			train:GetPhysicsObject():SetMass(50000)
			train:GetPhysicsObject():SetVelocity(Vector(-100000, 0, 0))
			train:EmitSound("ambient/alarms/train_horn2.wav", 130, 100, 1, 0, 0)

			timer.Simple(3, function() if train:IsValid() then train:Remove() end end)
		end

		self:BroadcastActionMsg("%caller% trainwrecked %targets%", { targets = targets })
	end)
end)

--[[
	Name: gimp
	Desc: Gimps a player in text chat, making them say bizarre things
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("gimp", function(cmd)
	cmd:SetDescription("Gimps a player in text chat, making them say bizarre things")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		local gimped = {}
		for _, v in ipairs(targets) do
			if not v.bsu_muted and not v.bsu_gimped then
				v.bsu_gimped = true
				table.insert(gimped, v)
			end
		end

		if next(gimped) ~= nil then
			self:BroadcastActionMsg("%caller% gimped %gimped%", {
				gimped = gimped
			})
		end
	end)
end)

--[[
	Name: ungimp
	Desc: Ungimps a player
	Arguments:
		1. Targets (players, default: self)
]]
BSU.SetupCommand("ungimp", function(cmd)
	cmd:SetDescription("Ungimps a player")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self)
		local targets = self:GetRawStringArg(1) and self:FilterTargets(self:GetPlayersArg(1, true), true) or { self:GetCaller(true) }

		local ungimped = {}
		for _, v in ipairs(targets) do
			if v.bsu_gimped then
				v.bsu_gimped = nil
				table.insert(ungimped, v)
			end
		end

		if next(ungimped) ~= nil then
			self:BroadcastActionMsg("%caller% ungimped %ungimped%", {
				ungimped = ungimped
			})
		end
	end)
end)

local gimpLines = {
	"guys",
	"can you hear me",
	"hello"
}

hook.Add("BSU_ChatCommand", "BSU_PlayerGimp", function(ply)
	if ply.bsu_gimped and not ply.bsu_muted then return gimpLines[math.random(1, #gimpLines)] end
end)

--[[
	Name: spectate
	Desc: Be one with the player
	Arguments:
		1. Message (string)
]]
BSU.SetupCommand("spectate", function(cmd)
	cmd:SetDescription("Be one with the player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(self)
		local target = self:GetPlayerArg(1, true)
		local caller = self:GetCaller(true)

		getSpawnInfo(target)

		caller.bsu_spectating = true
		caller:SetColor(Color(0, 0, 0, 0))
		caller:Spectate(OBS_MODE_IN_EYE)
		caller:SpectateEntity(target)
		caller:StripWeapons()

		self:PrintChatMsg("Spectating ", target)
	end)
end)

--[[
	Name: unspectate
	Desc: Unspectates a player
	Arguments:
		1. Message (string)
]]
BSU.SetupCommand("unspectate", function(cmd)
	cmd:SetDescription("Unspectates a player")
	cmd:SetCategory("utility")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetSilent(true)
	cmd:SetFunction(function(self)
		local caller = self:GetCaller(true)

		if caller.bsu_spectating then
			caller.bsu_spectating = nil
			caller:UnSpectate()
			doSpawn(caller)
			caller:SetColor(Color(255, 255, 255, 255))
		end

		self:PrintChatMsg("Stopped spectating")
	end)
end)

hook.Add("KeyPress", "BSU_StopSpectating", function(ply)
	if ply.bsu_spectating then
		BSU.SafeRunCommand(ply, "unspectate")
	end
end)