-- block players from doing various things if they're in an exclusive state

local function Block(ply)
	if ply.bsu_exclusive then return false end
end

-- not allowed while in exclusive state
hook.Add("CanPlayerSuicide", "BSU_BlockPlayer", Block)
hook.Add("PlayerNoClip", "BSU_BlockPlayer", Block)
hook.Add("PlayerSwitchWeapon", "BSU_BlockPlayer", function(ply) if Block(ply) == false then return true end end)

-- Block spawning entities
hook.Add("PlayerSpawnObject", "BSU_BlockPlayer", Block)
hook.Add("PlayerSpawnSENT", "BSU_BlockPlayer", Block)
hook.Add("PlayerSpawnVehicle", "BSU_BlockPlayer", Block)
hook.Add("PlayerSpawnNPC", "BSU_BlockPlayer", Block)
hook.Add("PlayerSpawnSWEP", "BSU_BlockPlayer", Block)

-- block permissions
hook.Add("BSU_PlayerHasPermission", "BSU_BlockPlayer", Block)

-- if player respawns, add back any flags they should have
hook.Add("PlayerSpawn", "BSU_SpawnAddFlags", function(ply)
	if ply.bsu_building or ply.bsu_godded or ply.bsu_frozen then ply:AddFlags(FL_GODMODE) end
	if ply.bsu_frozen then ply:AddFlags(FL_FROZEN) end
end)

-- prevent removing certain flags from players
hook.Add("BSU_CanRemoveFlags", "BSU_FunCanRemoveFlags", function(ply, flags)
	if bit.band(flags, FL_GODMODE) == FL_GODMODE and (ply.bsu_building or ply.bsu_godded or ply.bsu_frozen) then return false end
	if bit.band(flags, FL_FROZEN) == FL_FROZEN and ply.bsu_frozen then return false end
end)

local function AddFlags(ply, flags)
	if hook.Run("BSU_CanAddFlags", ply, flags) == false then return end
	ply:AddFlags(flags)
end

local function RemoveFlags(ply, flags)
	if hook.Run("BSU_CanRemoveFlags", ply, flags) == false then return end
	ply:RemoveFlags(flags)
end

-- handle build/pvp mode damaging

hook.Add("PlayerInitialSpawn", "BSU_BuildPVPInit", function(ply)
	ply.bsu_pvpblocked = {}
end)

hook.Add("PlayerDisconnected", "BSU_BuildPVPCleanup", function(ply)
	for _, v in ipairs(player.GetAll()) do
		v.bsu_pvpblocked[ply] = nil
	end
end)

hook.Add("PlayerShouldTakeDamage", "BSU_BuildPVPPreventDamage", function(ply, attacker)
	if not ply:IsPlayer() or not attacker:IsPlayer() then return end
	if ply ~= attacker and (attacker.bsu_building or ply.bsu_pvpblocked[attacker] or attacker.bsu_pvpblocked[ply]) then
		return false
	end
end)

BSU.SetupCommand("build", function(cmd)
	cmd:SetDescription("Enter into build mode")
	cmd:SetCategory("fun")
	cmd:SetFunction(function(self, caller)
		if caller.bsu_building then return end

		caller.bsu_building = true
		AddFlags(caller, FL_GODMODE)

		self:BroadcastActionMsg("%caller% entered build mode")
	end)
	cmd:SetValidCaller(true)
end)

BSU.SetupCommand("pvp", function(cmd)
	cmd:SetDescription("Enter into pvp mode")
	cmd:SetCategory("fun")
	cmd:SetFunction(function(self, caller)
		if not caller.bsu_building then return end

		caller.bsu_building = nil
		RemoveFlags(caller, FL_GODMODE)

		self:BroadcastActionMsg("%caller% entered pvp mode")
	end)
	cmd:SetValidCaller(true)
end)

BSU.SetupCommand("pvpblock", function(cmd)
	cmd:SetDescription("Block pvp between yourself and the players")
	cmd:SetCategory("fun")
	cmd:SetFunction(function(self, caller, targets)
		local blocked = {}

		for _, v in ipairs(targets) do
			if v ~= caller and not caller.bsu_pvpblocked[v] then
				caller.bsu_pvpblocked[v] = true
				table.insert(blocked, v)
			end
		end

		if next(blocked) ~= nil then
			self:BroadcastActionMsg("%caller% blocked pvp for %blocked%", { blocked = blocked })
		end
	end)
	cmd:SetValidCaller(true)
	cmd:AddPlayersArg("targets")
end)

BSU.SetupCommand("pvpunblock", function(cmd)
	cmd:SetDescription("Unblock pvp between yourself and the players")
	cmd:SetCategory("fun")
	cmd:SetFunction(function(self, caller, targets)
		if next(caller.bsu_pvpblocked) == nil then return end

		local unblocked = {}

		for _, v in ipairs(targets) do
			if v ~= caller and caller.bsu_pvpblocked[v] then
				caller.bsu_pvpblocked[v] = nil
				table.insert(unblocked, v)
			end
		end

		if next(unblocked) ~= nil then
			self:BroadcastActionMsg("%caller% unblocked pvp for %unblocked%", { unblocked = unblocked })
		end
	end)
	cmd:SetValidCaller(true)
	cmd:AddPlayersArg("targets")
end)

BSU.SetupCommand("god", function(cmd)
	cmd:SetDescription("Enable god on players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local godded = {}

		for _, v in ipairs(targets) do
			if not v.bsu_godded then
				v.bsu_godded = true
				AddFlags(v, FL_GODMODE)
				table.insert(godded, v)
			end
		end

		if next(godded) ~= nil then
			self:BroadcastActionMsg("%caller% godded %godded%", { godded = godded })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("ungod", function(cmd)
	cmd:SetDescription("Disable god on players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local ungodded = {}

		for _, v in ipairs(targets) do
			if v.bsu_godded then
				v.bsu_godded = nil
				RemoveFlags(v, FL_GODMODE)
				table.insert(ungodded, v)
			end
		end

		if next(ungodded) ~= nil then
			self:BroadcastActionMsg("%caller% ungodded %ungodded%", { ungodded = ungodded })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

local function Spectate(ply, ent)
	ply:Spectate(OBS_MODE_NONE) ply:SetObserverMode(OBS_MODE_CHASE) -- HACK: fixes needing to respawn the player after unspectating
	ply:SpectateEntity(ent)
	ply:SetSolid(SOLID_NONE)
	ply:PhysicsDestroy()
	ply:SetNoDraw(true)
	ply:DropObject()
	ply.bsu_old_wep = ply:GetActiveWeapon()
	ply:SetActiveWeapon()
end

local function Unspectate(ply)
	ply:Unspectate()
	ply:DrawViewModel(true)
	ply:PhysicsInit(SOLID_BBOX)
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetNoDraw(false)
	ply:SetActiveWeapon(ply.bsu_old_wep)
	ply.bsu_old_wep = nil
end

util.AddNetworkString("bsu_ragdoll_color")

local function RagdollPlayer(ply, owner)
	if IsValid(ply.bsu_ragdoll) then return false end

	local ragdoll = ents.Create("prop_ragdoll")
	if not IsValid(ragdoll) then return false end

	if owner:IsPlayer() then
		BSU.SetOwner(ragdoll, owner)
	else
		BSU.SetOwnerWorld(ragdoll)
	end
	ragdoll:SetModel(ply:GetModel())
	ragdoll:Spawn()
	ragdoll:Activate()

	net.Start("bsu_ragdoll_color")
	net.WriteUInt(ragdoll:EntIndex(), 13) -- MAX_EDICT_BITS
	net.WriteVector(ply:GetPlayerColor())
	net.Broadcast()

	ragdoll:CallOnRemove("BSU_Ragdoll", function()
		if not ply:IsValid() then return end
		Unspectate(ply)
		timer.Simple(0, function()
			if not ply:IsValid() then return end
			RagdollPlayer(ply, owner)
		end)
	end)

	local vel = ply:GetVelocity()

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local phys = ragdoll:GetPhysicsObjectNum(i)
		if not IsValid(phys) then continue end

		local boneid = ragdoll:TranslatePhysBoneToBone(i)
		if boneid < 0 then continue end

		local matrix = ply:GetBoneMatrix(boneid)
		if not matrix then continue end

		phys:SetPos(matrix:GetTranslation())
		phys:SetAngles(matrix:GetAngles())
		phys:AddVelocity(vel)
	end

	if ply:InVehicle() then ply:ExitVehicle() end

	ply.bsu_ragdoll = ragdoll

	Spectate(ply, ragdoll)

	return true
end

local function UnragdollPlayer(ply)
	if not IsValid(ply.bsu_ragdoll) then return false end

	Unspectate(ply)

	ply:SetVelocity(ply.bsu_ragdoll:GetVelocity())
	ply.bsu_ragdoll:RemoveCallOnRemove("BSU_Ragdoll")
	ply.bsu_ragdoll:Remove()
	ply.bsu_ragdoll = nil

	return true
end

-- if ragdolled player somehow respawns, make them Spectate their ragdoll again
hook.Add("PlayerSpawn", "BSU_FixRagdollRespawn", function(ply)
	if not ply.bsu_ragdoll then return end
	timer.Simple(0, function()
		if not ply:IsValid() then return end
		if not ply.bsu_ragdoll then return end
		Spectate(ply, ply.bsu_ragdoll)
	end)
end)

-- if ragdolled player disconnected, delete their ragdoll
hook.Add("PlayerDisconnected", "BSU_RemoveRagdoll", function(ply)
	if not ply.bsu_ragdoll then return end
	ply.bsu_ragdoll:RemoveCallOnRemove("BSU_Ragdoll")
	ply.bsu_ragdoll:Remove()
end)

BSU.SetupCommand("ragdoll", function(cmd)
	cmd:SetDescription("Set players into ragdoll mode")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, caller, targets)
		local ragdolled = {}

		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) and RagdollPlayer(v, caller) then -- successfully ragdolled
				self:SetExclusive(v, "ragdolled")
				table.insert(ragdolled, v)
			end
		end

		if next(ragdolled) ~= nil then
			self:BroadcastActionMsg("%caller% ragdolled %ragdolled%", { ragdolled = ragdolled })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("unragdoll", function(cmd)
	cmd:SetDescription("Set players out of ragdoll mode")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local unragdolled = {}

		for _, v in ipairs(targets) do
			if UnragdollPlayer(v) then -- successfully unragdolled
				self:ClearExclusive(v)
				table.insert(unragdolled, v)
			end
		end

		if next(unragdolled) ~= nil then
			self:BroadcastActionMsg("%caller% unragdolled %unragdolled%", { unragdolled = unragdolled })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

-- right-click freezing/unfreezing functionality when physgunning a player

hook.Add("BSU_PlayerPhysgunDrop", "BSU_PlayerPhysgunFreeze", function(ply, target)
	if ply:KeyDown(IN_ATTACK2) and BSU.PlayerHasCommandAccess(ply, "freeze") then
		BSU.SafeRunCommand(ply, "freeze", "$" .. target:UserID())
	end
end)

hook.Add("BSU_PlayerPhysgunPickup", "BSU_PlayerPhysgunUnfreeze", function(ply, target)
	if BSU.PlayerHasCommandAccess(ply, "unfreeze") then
		BSU.SafeRunCommand(ply, "unfreeze", "$" .. target:UserID())
	end
end)

BSU.SetupCommand("freeze", function(cmd)
	cmd:SetDescription("Make players unable to move")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local frozen = {}

		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) and not v.bsu_frozen then
				v.bsu_frozen = true
				self:SetExclusive(v, "frozen")
				AddFlags(v, FL_FROZEN)
				AddFlags(v, FL_GODMODE)
				v:SetMoveType(MOVETYPE_NONE)
				v:SetVelocity(-v:GetVelocity())
				table.insert(frozen, v)
			end
		end

		if next(frozen) ~= nil then
			self:BroadcastActionMsg("%caller% froze %frozen%", { frozen = frozen })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("unfreeze", function(cmd)
	cmd:SetDescription("Make players able to move again")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local unfrozen = {}

		for _, v in ipairs(targets) do
			if v.bsu_frozen then
				v.bsu_frozen = nil
				self:ClearExclusive(v)
				RemoveFlags(v, FL_FROZEN)
				RemoveFlags(v, FL_GODMODE)
				v:SetMoveType(MOVETYPE_WALK)
				table.insert(unfrozen, v)
			end
		end

		if next(unfrozen) ~= nil then
			self:BroadcastActionMsg("%caller% unfroze %unfrozen%", { unfrozen = unfrozen })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)
BSU.AliasCommand("thaw", "unfreeze")

BSU.SetupCommand("health", function(cmd)
	cmd:SetDescription("Set health of players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets, amount)
		for _, v in ipairs(targets) do
			v:SetHealth(amount)
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% set the health of %targets% to %amount%", { targets = targets, amount = amount })
		end
	end)
	cmd:AddPlayersArg("targets", { filter = true })
	cmd:AddNumberArg("amount", { min = 0, max = 2 ^ 31 - 1 })
end)
BSU.AliasCommand("hp", "health")

BSU.SetupCommand("armor", function(cmd)
	cmd:SetDescription("Set armor of players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets, amount)
		for _, v in ipairs(targets) do
			v:SetArmor(amount)
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% set the armor of %targets% to %amount%", { targets = targets, amount = amount })
		end
	end)
	cmd:AddPlayersArg("targets", { filter = true })
	cmd:AddNumberArg("amount", { min = 0, max = 2 ^ 31 - 1 })
end)
BSU.AliasCommand("suit", "armor")

BSU.SetupCommand("launch", function(cmd)
	cmd:SetDescription("Launch players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		for _, v in ipairs(targets) do
			v:SetVelocity(Vector(0, 0, 5000))
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% launched %targets%", { targets = targets })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("respawn", function(cmd)
	cmd:SetDescription("Respawn players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		for _, v in ipairs(targets) do
			v:Spawn()
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% respawned %targets%", { targets = targets })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("slay", function(cmd)
	cmd:SetDescription("Slay players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		for _, v in ipairs(targets) do
			v:Kill()
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% slayed %targets%", { targets = targets })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)
BSU.AliasCommand("kill", "slay")

BSU.SetupCommand("dissolve", function(cmd)
	cmd:SetDescription("Dissolve players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		for _, v in ipairs(targets) do
			v:Kill()
			v:CreateRagdoll()
			local ent = v:GetRagdollEntity()
			if ent:IsValid() then
				ent:Dissolve(1)
				ent:EmitSound(string.format("ambient/levels/labs/electric_explosion%d.wav", math.random(1, 3)), nil, nil, nil, CHAN_STATIC)
			end
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% dissolved %targets%", { targets = targets })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)
BSU.AliasCommand("smite", "dissolve")

BSU.SetupCommand("explode", function(cmd)
	cmd:SetDescription("Explode players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local dmgInfo = DamageInfo()
		dmgInfo:SetDamageType(DMG_BLAST)

		for _, v in ipairs(targets) do
			local explosion = ents.Create("env_explosion")
			explosion:SetPos(v:GetPos())
			explosion:Spawn()

			explosion:Fire("Explode")
			explosion:EmitSound("BaseExplosionEffect.Sound")

			dmgInfo:SetDamage(math.max(v:Health(), 1))
			dmgInfo:SetAttacker(v)
			v:RemoveFlags(FL_GODMODE)
			v:SetArmor(0)
			v:TakeDamageInfo(dmgInfo)
		end

		if next(targets) ~= nil then
			self:BroadcastActionMsg("%caller% exploded %targets%", { targets = targets })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("enter", function(cmd)
	cmd:SetDescription("Force a player into the vehicle you're looking at")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, target)
		if not target:InVehicle() then
			local vehicle = self:GetCaller(true):GetEyeTrace().Entity
			if not vehicle:IsVehicle() then return end
			target:EnterVehicle(vehicle)
		end

		self:BroadcastActionMsg("%caller% forced %target% into a vehicle", { target = target })
	end)
	cmd:AddPlayerArg("target", { default = "^", check = true })
end)

BSU.SetupCommand("eject", function(cmd)
	cmd:SetDescription("Eject players from the vehicle they're in")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
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
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("notification", function(cmd)
	cmd:SetDescription("Send a notification to players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(_, _, targets, msg)
		BSU.ClientRPC(targets, "notification.AddLegacy", msg, NOTIFY_GENERIC, 5)
		BSU.ClientRPC(targets, "surface.PlaySound", "buttons/button15.wav")
	end)
	cmd:AddPlayersArg("targets", { filter = true })
	cmd:AddStringArg("message", { multi = true })
end)
BSU.AliasCommand("notify", "notification")

BSU.SetupCommand("earthquake", function(cmd)
	cmd:SetDescription("Shake the ground for players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets, duration)
		BSU.ClientRPC(targets, "util.ScreenShake", Vector(), 100, 100, duration, 0)
		self:BroadcastActionMsg("%caller% shook the ground for %targets% for %duration% second" .. (duration ~= 1 and "s" or ""), { targets = targets, duration = duration })
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
	cmd:AddNumberArg("duration", { default = "10", min = 1, max = 10, allowtime = true })
end)
BSU.AliasCommand("shake", "earthquake")

BSU.SetupCommand("setammo", function(cmd)
	cmd:SetDescription("Set the ammo for players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets, amount)
		for _, v in ipairs(targets) do
			local wep = v:GetActiveWeapon()
			if wep:IsValid() then
				v:SetAmmo(amount, wep:GetPrimaryAmmoType())
				v:SetAmmo(amount, wep:GetSecondaryAmmoType())
			end
		end

		self:BroadcastActionMsg("%caller% set the ammo for %targets% to %amount%", { targets = targets, amount = amount })
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
	cmd:AddNumberArg("amount", { default = "9999", min = 0, max = 9999 })
end)
BSU.AliasCommand("ammo", "setammo")

local infammoPlys = {}

hook.Add("Think", "BSU_InfAmmo", function()
	for ply, _ in pairs(infammoPlys) do
		if not ply:IsValid() then
			infammoPlys[ply] = nil
		else
			local wep = ply:GetActiveWeapon()
			if wep:IsValid() then
				wep:SetClip1(wep:GetMaxClip1())
				wep:SetClip2(wep:GetMaxClip2())
				ply:SetAmmo(9999, wep:GetPrimaryAmmoType())
				ply:SetAmmo(9999, wep:GetSecondaryAmmoType())
			end
		end
	end
end)

BSU.SetupCommand("infammo", function(cmd)
	cmd:SetDescription("Set infinite ammo for players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local infammoed = {}

		for _, v in ipairs(targets) do
			if not infammoPlys[v] then
				infammoPlys[v] = true
				table.insert(infammoed, v)
			end
		end

		if next(infammoed) ~= nil then
			self:BroadcastActionMsg("%caller% set infinite ammo for %infammoed%", { infammoed = infammoed })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("limammo", function(cmd)
	cmd:SetDescription("Set limited ammo for players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local limammoed = {}

		for _, v in ipairs(targets) do
			if infammoPlys[v] then
				infammoPlys[v] = nil
				table.insert(limammoed, v)
			end
		end

		if next(limammoed) ~= nil then
			self:BroadcastActionMsg("%caller% set limited ammo for %limammoed%", { limammoed = limammoed })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

local function SetCollisionTarget(ent, target)
	hook.Add("ShouldCollide", ent, function(_, ent1, ent2)
		if ent1 ~= target and ent2 ~= target then return false end
	end)
	ent:SetCustomCollisionCheck(true)
end

BSU.SetupCommand("bathe", function(cmd)
	cmd:SetDescription("Throw a bathtub at players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		for _, v in ipairs(targets) do
			if not v.bsu_frozen then v:RemoveFlags(FL_GODMODE) end
			if v:InVehicle() then v:ExitVehicle() end
			if v:GetMoveType() == MOVETYPE_NOCLIP then v:SetMoveType(MOVETYPE_WALK) end

			local bath = ents.Create("prop_physics")
			BSU.SetOwnerWorld(bath)
			bath:SetModel("models/props_interiors/BathTub01a.mdl")
			bath:SetAngles(Angle(0, 180, 0))
			bath:SetPos(v:GetPos() + Vector(750, 0, 50))
			SetCollisionTarget(bath, v)
			bath:Spawn()

			local phys = bath:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableGravity(false)
				phys:SetMass(50000)
				phys:SetVelocity(Vector(-100000, 0, 0))
			end
			bath:EmitSound("Physics.WaterSplash", 100)

			timer.Simple(3, function() if bath:IsValid() then bath:Remove() end end)
		end

		self:BroadcastActionMsg("%caller% bathed %targets%", { targets = targets })
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("trainwreck", function(cmd)
	cmd:SetDescription("Throw a train at players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		for _, v in ipairs(targets) do
			if not v.bsu_frozen then v:RemoveFlags(FL_GODMODE) end
			if v:InVehicle() then v:ExitVehicle() end
			if v:GetMoveType() == MOVETYPE_NOCLIP then v:SetMoveType(MOVETYPE_WALK) end

			local train = ents.Create("prop_physics")
			BSU.SetOwnerWorld(train)
			train:SetModel("models/props_trainstation/train001.mdl")
			train:SetAngles(Angle(0, 90, 0))
			train:SetPos(v:GetPos() + Vector(750, 0, 150))
			SetCollisionTarget(train, v)
			train:Spawn()

			local phys = train:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableGravity(false)
				phys:SetMass(50000)
				phys:SetVelocity(Vector(-100000, 0, 0))
			end
			train:EmitSound("ambient/alarms/train_horn2.wav", 100)

			timer.Simple(3, function() if train:IsValid() then train:Remove() end end)
		end

		self:BroadcastActionMsg("%caller% trainwrecked %targets%", { targets = targets })
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("gimp", function(cmd)
	cmd:SetDescription("Gimp players in text chat, making them say bizarre things")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local gimped = {}

		for _, v in ipairs(targets) do
			if not v.bsu_muted and not v.bsu_gimped then
				v.bsu_gimped = true
				table.insert(gimped, v)
			end
		end

		if next(gimped) ~= nil then
			self:BroadcastActionMsg("%caller% gimped %gimped%", { gimped = gimped })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

BSU.SetupCommand("ungimp", function(cmd)
	cmd:SetDescription("Ungimp players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local ungimped = {}
		for _, v in ipairs(targets) do
			if v.bsu_gimped then
				v.bsu_gimped = nil
				table.insert(ungimped, v)
			end
		end

		if next(ungimped) ~= nil then
			self:BroadcastActionMsg("%caller% ungimped %ungimped%", { ungimped = ungimped })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

local gimpLines = {
	"guys",
	"can you hear me",
	"hello"
}

hook.Add("BSU_ChatCommand", "BSU_PlayerGimp", function(ply)
	if ply.bsu_gimped and not ply.bsu_muted then return gimpLines[math.random(1, #gimpLines)] end
end)

BSU.SetupCommand("ignite", function(cmd)
	cmd:SetDescription("Light players on fire")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets, duration)
		for _, ply in ipairs(targets) do
			ply:Ignite(duration)
		end
	self:BroadcastActionMsg("%caller% ignited %targets% for %duration% seconds", { targets = targets, duration = duration })
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
	cmd:AddNumberArg("duration", { default = "10", min = 1, max = 60, allowtime = true })
end)

BSU.SetupCommand("unignite", function(cmd)
	cmd:SetDescription("Extinguish players on fire")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		for _, ply in ipairs(targets) do
			ply:Extinguish()
		end
	self:BroadcastActionMsg("%caller% extinguished %targets%", { targets = targets })
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

local jailTemplate = {
	{ ang = Angle(0, 0, 0), pos = Vector(0, 0, -10), mdl = "models/props_junk/wood_pallet001a.mdl" },
	{ ang = Angle(0, 0, 0), pos = Vector(0, 0, 115), mdl = "models/props_junk/wood_pallet001a.mdl" },

	{ ang = Angle(0, 0, 0), pos = Vector(-30, 0, 35), mdl = "models/props_c17/fence01b.mdl" },
	{ ang = Angle(0, 0, 0), pos = Vector(30, 0, 35), mdl = "models/props_c17/fence01b.mdl" },

	{ ang = Angle(0, 90, 0), pos = Vector(0, -35, 50), mdl = "models/props_wasteland/interior_fence002e.mdl" },
	{ ang = Angle(0, 90, 0), pos = Vector(0, -35, 50), mdl = "models/props_wasteland/interior_fence001g.mdl" },
	{ ang = Angle(0, 90, 0), pos = Vector(0,  35, 50), mdl = "models/props_wasteland/interior_fence002e.mdl" },
	{ ang = Angle(0, 90, 0), pos = Vector(0,  35, 50), mdl = "models/props_wasteland/interior_fence001g.mdl" },
}
local jailMin = Vector(-30, -35, -10)
local jailMax = Vector(30,  35, 115)

BSU.SetupCommand("jail", function(cmd)
	cmd:SetDescription("Prosecute players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets, _duration)
		local jailed = {}

		for _, v in ipairs(targets) do
			if self:CheckExclusive(v, true) and not v.bsu_jailed then
				self:SetExclusive(v, "jailed")

				local entities = {}
				for _, data in ipairs(jailTemplate) do
					local ent = ents.Create("prop_physics")
					BSU.SetOwnerWorld(ent)
					ent:SetModel(data.mdl)
					ent:SetPos(v:GetPos() + data.pos)
					ent:SetAngles(data.ang)
					ent:Spawn()

					local phys = ent:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
					end

					table.insert(entities, ent)
				end

				v.bsu_jailed = {
					origin = v:GetPos(),
					entities = entities,
				}

				table.insert(jailed, v)
			end
		end

		if next(jailed) ~= nil then
			self:BroadcastActionMsg("%caller% jailed %jailed%", { jailed = jailed })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
	cmd:AddNumberArg("duration", { default = "0", allowtime = true })
end)

BSU.SetupCommand("unjail", function(cmd)
	cmd:SetDescription("Unjail players")
	cmd:SetCategory("fun")
	cmd:SetAccess(BSU.CMD_ADMIN)
	cmd:SetFunction(function(self, _, targets)
		local unjailed = {}

		for _, v in ipairs(targets) do
			if v.bsu_jailed then
				self:ClearExclusive(v)
				for _, ent in ipairs(v.bsu_jailed.entities or {}) do
					if ent:IsValid() then
						ent:Remove()
					end
				end
				v.bsu_jailed = nil
				table.insert(unjailed, v)
			end
		end

		if next(unjailed) ~= nil then
			self:BroadcastActionMsg("%caller% unjailed %unjailed%", { unjailed = unjailed })
		end
	end)
	cmd:AddPlayersArg("targets", { default = "^", filter = true })
end)

hook.Add("Tick", "BSU_Jailed", function()
	for _, ply in ipairs(player.GetAll()) do
		if ply.bsu_jailed then
			local withinJail = ply:GetPos():WithinAABox(ply.bsu_jailed.origin + jailMin, ply.bsu_jailed.origin + jailMax)
			if not withinJail then
				ply:SetPos(ply.bsu_jailed.origin)
			end
		end
	end
end)
