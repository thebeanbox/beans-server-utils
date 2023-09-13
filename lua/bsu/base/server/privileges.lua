-- base/server/privileges.lua

local function isAllowed(ply, type, priv)
	if ply:IsSuperAdmin() then return true end
	local check = BSU.CheckPlayerPrivilege(ply:SteamID64(), type, priv, true) -- also check wildcards
	return check == nil or check == true
end

local function notifyRestricted(ply, name)
	BSU.ClientRPC(ply, "chat.AddText", BSU.CLR_ERROR, "'" .. name .. "' is restricted")
end

local function checkModelPrivilege(ply, model)
	local allowed = isAllowed(ply, BSU.PRIV_MODEL, model)
	if not allowed then
		notifyRestricted(ply, string.match(model, "^models/.+%.mdl"))
		return false
	end
end

local function checkNPCPrivilege(ply, npc)
	local allowed = isAllowed(ply, BSU.PRIV_NPC, npc)
	if not allowed then
		notifyRestricted(ply, npc)
		return false
	end
end

local function checkSENTPrivilege(ply, ent)
	local allowed = isAllowed(ply, BSU.PRIV_SENT, ent)
	if not allowed then
		notifyRestricted(ply, ent)
		return false
	end
end

local function checkSWEPPrivilege(ply, wep)
	local allowed = isAllowed(ply, BSU.PRIV_SWEP, wep)
	if not allowed then
		notifyRestricted(ply, wep)
		return false
	end
end

-- note: if the server cvar 'toolmode_allow_<tool>' is set to 0 then this doesn't get called
local function checkToolPrivilege(ply, _, tool)
	local allowed = isAllowed(ply, BSU.PRIV_TOOL, tool)
	if not allowed then
		notifyRestricted(ply, tool)
		return false
	end
end

hook.Add("PlayerSpawnObject", "BSU_CheckModelPrivilege", checkModelPrivilege)

hook.Add("PlayerSpawnVehicle", "BSU_CheckModelPrivilege", checkModelPrivilege)

hook.Add("PlayerSpawnNPC", "BSU_CheckNPCPrivilege", checkNPCPrivilege)

hook.Add("PlayerSpawnSENT", "BSU_CheckSENTPrivilege", checkSENTPrivilege)

hook.Add("PlayerSpawnSWEP", "BSU_CheckSWEPPrivilege", checkSWEPPrivilege)

hook.Add("PlayerGiveSWEP", "BSU_CheckSWEPPrivilege", checkSWEPPrivilege)

hook.Add("CanTool", "BSU_CheckToolPrivilege", checkToolPrivilege)