if SERVER then
	util.AddNetworkString("bsu_logs")

	local function WritePlayer(ply)
		net.WriteColor(team.GetColor(ply:Team()))
		net.WriteString(ply:Nick())
		if not ply:IsBot() then
			net.WriteBool(true)
			net.WriteUInt64(ply:SteamID64())
		else
			net.WriteBool(false)
		end
	end

	local function LogDupe(ply, name, entCount, constrCount)
		net.Start("bsu_logs")
			WritePlayer(ply)
			net.WriteUInt(0, 2)
		if name then
			net.WriteBool(true)
			net.WriteString(name)
		else
			net.WriteBool(false)
			end
			net.WriteUInt(entCount, 13)
			net.WriteUInt(constrCount, 13)
		net.Broadcast()
	end

	local function LogSpawn(ply, type, model)
		net.Start("bsu_logs")
			WritePlayer(ply)
			net.WriteUInt(1, 2)
			net.WriteUInt(type, 8)
			net.WriteString(model)
		net.Broadcast()
	end

	local function LogTool(ply, name, class)
		net.Start("bsu_logs")
			WritePlayer(ply)
			net.WriteUInt(2, 2)
			net.WriteString(name)
			net.WriteString(class)
		net.Broadcast()
	end

	hook.Add("OnGamemodeLoaded", "BSU_LogPlayerPastedDupe", function()
		BSU.DetourWrap("AdvDupe2.InitPastingQueue", "BSU_LogPlayerPastedDupe", function(args)
			local ply = args[1]
			local Queue = AdvDupe2.JobManager.Queue
			Queue = Queue[#Queue]
			LogDupe(ply, ply.AdvDupe2.Name, #Queue.SortedEntities, #Queue.ConstraintList)
		end)

		BSU.DetourBefore("AdvDupe.Paste", "BSU_LogPlayerPastedDupe", function(ply, entityList, constraintList)
			LogDupe(ply, nil, table.Count(entityList), table.Count(constraintList))
		end)

		BSU.DetourBefore("duplicator.Paste", "BSU_LogPlayerPastedDupe", function(ply, entityList, constraintList)
			LogDupe(ply, nil, table.Count(entityList), table.Count(constraintList))
		end)
	end)

	hook.Add("PlayerSpawnedEffect", "BSU_LogPlayerSpawnedEffect", function(ply, model)
		LogSpawn(ply, BSU.LOG_SPAWN_EFFECT, model)
	end)

	hook.Add("PlayerSpawnedNPC", "BSU_LogPlayerSpawnedNPC", function(ply, ent)
		LogSpawn(ply, BSU.LOG_SPAWN_NPC, ent:GetClass())
	end)

	hook.Add("PlayerSpawnedProp", "BSU_LogPlayerSpawnedProp", function(ply, model)
		LogSpawn(ply, BSU.LOG_SPAWN_PROP, model)
	end)

	hook.Add("PlayerSpawnedRagdoll", "BSU_LogPlayerSpawnedRagdoll", function(ply, model)
		LogSpawn(ply, BSU.LOG_SPAWN_RAGDOLL, model)
	end)

	hook.Add("PlayerSpawnedSENT", "BSU_LogPlayerSpawnedSENT", function(ply, ent)
		LogSpawn(ply, BSU.LOG_SPAWN_SENT, ent:GetClass())
	end)

	hook.Add("PlayerSpawnedSWEP", "BSU_LogPlayerSpawnedSWEP", function(ply, ent)
		LogSpawn(ply, BSU.LOG_SPAWN_SWEP, ent:GetClass())
	end)

	hook.Add("PlayerSpawnedVehicle", "BSU_LogPlayerSpawnedVehicle", function(ply, ent)
		LogSpawn(ply, BSU.LOG_SPAWN_VEHICLE, ent:GetClass())
	end)

	hook.Add("CanTool", "BSU_LogPlayerUsedTool", function(ply, tr, name)
		LogTool(ply, name, tr.Entity:GetClass())
	end)

	return
end

local function LogDupe(plyColor, plyName, plySteamID, name, entCount, constrCount)
	if name then
		MsgC(
			BSU.LOG_CLR_DUPE, "[DUPE] ",
			plyColor, plyName,
			BSU.LOG_CLR_PARAM, "<", plySteamID, ">",
			BSU.LOG_CLR_TEXT, " pasted a dupe '",
			BSU.LOG_CLR_PARAM, name,
			BSU.LOG_CLR_TEXT, "' with ",
			BSU.LOG_CLR_PARAM, entCount,
			BSU.LOG_CLR_TEXT, " entit", entCount == 1 and "y" or "ies", " and ",
			BSU.LOG_CLR_PARAM, constrCount,
			BSU.LOG_CLR_TEXT, " constraint", constrCount == 1 and "" or "s", "\n"
		)
	else
		MsgC(
			BSU.LOG_CLR_DUPE, "[DUPE] ",
			plyColor, plyName,
			BSU.LOG_CLR_PARAM, "<", plySteamID, ">",
			BSU.LOG_CLR_TEXT, " pasted a dupe with ",
			BSU.LOG_CLR_PARAM, entCount,
			BSU.LOG_CLR_TEXT, " entit", entCount == 1 and "y" or "ies", " and ",
			BSU.LOG_CLR_PARAM, constrCount,
			BSU.LOG_CLR_TEXT, " constraint", constrCount == 1 and "" or "s", "\n"
		)
	end
end

local logSpawnName = {
	"effect", "NPC", "prop", "ragdoll", "SENT", "SWEP", "vehicle"
}

local function LogSpawn(plyColor, plyName, plySteamID, type, model)
	MsgC(
		BSU.LOG_CLR_SPAWN, "[SPAWN] ",
		plyColor, plyName,
		BSU.LOG_CLR_PARAM, "<", plySteamID, ">",
		BSU.LOG_CLR_TEXT, " spawned ", logSpawnName[type], " ",
		BSU.LOG_CLR_PARAM, model, "\n"
	)
end

local function LogTool(plyColor, plyName, plySteamID, name, class)
	MsgC(
		BSU.LOG_CLR_TOOL, "[TOOL] ",
		plyColor, plyName,
		BSU.LOG_CLR_PARAM, "<", plySteamID, ">",
		BSU.LOG_CLR_TEXT, " used tool ",
		BSU.LOG_CLR_PARAM, name,
		BSU.LOG_CLR_TEXT, " on ",
		BSU.LOG_CLR_PARAM, class, "\n"
	)
end

local function ReadPlayer()
	local color = net.ReadColor()
	local name = net.ReadString()
	local steamid = net.ReadBool() and util.SteamIDFrom64(net.ReadUInt64()) or "BOT"
	return color, name, steamid
end

net.Receive("bsu_logs", function()
	local plyColor, plyName, plySteamID = ReadPlayer()
	local log = net.ReadUInt(2)
	if log == 0 then
		local name = net.ReadBool() and net.ReadString() or nil
		local entCount = net.ReadUInt(13)
		local constrCount = net.ReadUInt(13)
		LogDupe(plyColor, plyName, plySteamID, name, entCount, constrCount)
	elseif log == 1 then
		local type = net.ReadUInt(8)
		local model = net.ReadString()
		LogSpawn(plyColor, plyName, plySteamID, type, model)
	elseif log == 2 then
		local name = net.ReadString()
		local class = net.ReadString()
		LogTool(plyColor, plyName, plySteamID, name, class)
	end
end)
