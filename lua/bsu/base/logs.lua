if SERVER then

	util.AddNetworkString("bsu_logspawn")
	util.AddNetworkString("bsu_logdupe")
	util.AddNetworkString("bsu_logtool")

	local function LogDupe(dupePly, dupeName, dupeEntityAmount, dupeConstraintAmount)
		net.Start("bsu_logdupe")
		net.WriteEntity(dupePly)
		net.WriteString(dupeName)
		net.WriteUInt(dupeEntityAmount, 16)
		net.WriteUInt(dupeConstraintAmount, 16)
		net.Broadcast()
	end
	
	local function LogSpawn(spawnType, spawnPly, spawnModel)
		net.Start("bsu_logspawn")
		net.WriteUInt(spawnType, 8)
		net.WriteEntity(spawnPly)
		net.WriteString(spawnModel)
		net.Broadcast()
	end
	
	local function LogTool(toolPly, toolName, toolHitClass)
		net.Start("bsu_logtool")
		net.WriteEntity(toolPly)
		net.WriteString(toolName)
		net.WriteString(toolHitClass)
		net.Broadcast()
	end
	
	BSU._oldAdvDupe2Paste = BSU._oldAdvDupe2Paste or AdvDupe2.InitPastingQueue
	AdvDupe2.InitPastingQueue = function(Player, PositionOffset, AngleOffset, OrigPos, Constrs, Parenting, DisableParents, DisableProtection)
		BSU._oldAdvDupe2Paste(Player, PositionOffset, AngleOffset, OrigPos, Constrs, Parenting, DisableParents, DisableProtection)
		local Queue = AdvDupe2.JobManager.Queue[#AdvDupe2.JobManager.Queue]
		LogDupe(Player, Player.AdvDupe2.Name and Player.AdvDupe2.Name or "[Unnamed]", #Queue.SortedEntities, #Player.AdvDupe2.Constraints)
	end
	
	hook.Add("PlayerSpawnedEffect", "bsu_logPlayerSpawnedEffect", function(spawnPly, spawnModel, _)
		LogSpawn(BSU.LOG_SPAWN_EFFECT, spawnPly, spawnModel)
	end)

	hook.Add("PlayerSpawnedNPC", "bsu_logPlayerSpawnedNPC", function(spawnPly, spawnEntity)
		LogSpawn(BSU.LOG_SPAWN_NPC, spawnPly, spawnEntity:GetClass())
	end)

	hook.Add("PlayerSpawnedProp", "bsu_logPlayerSpawnedProp", function(spawnPly, spawnModel, _)
		LogSpawn(BSU.LOG_SPAWN_PROP, spawnPly, spawnModel)
	end)

	hook.Add("PlayerSpawnedRagdoll", "bsu_logPlayerSpawnedRagdoll", function(spawnPly, spawnModel, _)
		LogSpawn(BSU.LOG_SPAWN_RAGDOLL, spawnPly, spawnModel)
	end)

	hook.Add("PlayerSpawnedSENT", "bsu_logPlayerSpawnedSENT", function(spawnPly, spawnEntity)
		LogSpawn(BSU.LOG_SPAWN_SENT, spawnPly, spawnEntity:GetClass())
	end)

	hook.Add("PlayerSpawnedSWEP", "bsu_logPlayerSpawnedSWEP", function(spawnPly, spawnEntity)
		LogSpawn(BSU.LOG_SPAWN_SWEP, spawnPly, spawnEntity:GetClass())
	end)

	hook.Add("PlayerSpawnedVehicle", "bsu_logPlayerSpawnedVehicle", function(spawnPly, spawnEntity)
		LogSpawn(BSU.LOG_SPAWN_VEHICLE, spawnPly, spawnEntity:GetClass())
	end)
	
	hook.Add("CanTool", "bsu_logPlayerTool", function(toolPly, toolTrace, toolName, tool, _)
		LogTool(toolPly, toolName, toolTrace.Entity:GetClass())
	end)

else

	local function LogDupe(dupePly, dupeName, dupeEntityAmount, dupeConstraintAmount)
		MsgC(
			BSU.LOG_CLR_ADVDUPE2, "[ADVDUPE2] ",
			team.GetColor(dupePly:Team()), dupePly:Nick(),
			BSU.LOG_CLR_PARAM, "<" .. dupePly:SteamID() .. ">",
			BSU.LOG_CLR_TEXT, " spawned a dupe \"",
			BSU.LOG_CLR_PARAM, dupeName,
			BSU.LOG_CLR_TEXT, "\" [",
			BSU.LOG_CLR_PARAM, tostring(dupeEntityAmount),
			BSU.LOG_CLR_TEXT, " entities, ",
			BSU.LOG_CLR_PARAM, tostring(dupeConstraintAmount),
			BSU.LOG_CLR_TEXT, " constraints]\n"
		)
	end

	local logSpawnName = {
		"effect", "NPC", "prop", "ragdoll", "SENT", "SWEP", "vehicle"
	}

	local function LogSpawn(spawnType, spawnPly, spawnModel)
		MsgC(
			BSU.LOG_CLR_SPAWN, "[SPAWN] ",
			team.GetColor(spawnPly:Team()), spawnPly:Nick(),
			BSU.LOG_CLR_PARAM, "<" .. spawnPly:SteamID() .. ">",
			BSU.LOG_CLR_TEXT, " spawned ",
			BSU.LOG_CLR_PARAM, logSpawnName[spawnType],
			BSU.LOG_CLR_TEXT, " \"",
			BSU.LOG_CLR_PARAM, spawnModel,
			BSU.LOG_CLR_TEXT, "\"\n"
		)
	end

	local function LogTool(toolPly, toolName, toolHitClass)
		MsgC(
			BSU.LOG_CLR_SPAWN, "[TOOL] ",
			team.GetColor(toolPly:Team()), toolPly:Nick(),
			BSU.LOG_CLR_PARAM, "<" .. toolPly:SteamID() .. ">",
			BSU.LOG_CLR_TEXT, " used tool ",
			BSU.LOG_CLR_PARAM, toolName,
			BSU.LOG_CLR_TEXT, " on \"",
			BSU.LOG_CLR_PARAM, toolHitClass,
			BSU.LOG_CLR_TEXT, "\"\n"
		)
	end

	net.Receive("bsu_logspawn", function()
		local spawnType = net.ReadUInt(8)
		local spawnPly = net.ReadEntity()
		local spawnModel = net.ReadString()
		LogSpawn(spawnType, spawnPly, spawnModel)
	end)

	net.Receive("bsu_logdupe", function()
		local dupePly = net.ReadEntity()
		local dupeName = net.ReadString()
		local dupeEntityAmount = net.ReadUInt(16)
		local dupeConstraintAmount = net.ReadUInt(16)
		LogDupe(dupePly, dupeName, dupeEntityAmount, dupeConstraintAmount)
	end)

	net.Receive("bsu_logtool", function()
		local toolPly = net.ReadEntity()
		local toolName = net.ReadString()
		local toolHitClass = net.ReadString()
		LogTool(toolPly, toolName, toolHitClass)
	end)
	
end