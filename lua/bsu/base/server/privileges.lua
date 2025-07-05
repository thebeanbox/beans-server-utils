-- base/server/privileges.lua

local function IsAllowed(ply, type, priv)
	if ply:IsSuperAdmin() then return true end
	local check = BSU.CheckPlayerPrivilege(ply:SteamID64(), type, priv, true) -- also check wildcards
	return check == nil or check == true
end

local function NotifyRestricted(ply, name)
	BSU.ClientRPC(ply, "chat.AddText", BSU.CLR_ERROR, "'" .. name .. "' is restricted")
end

local function CheckModelPrivilege(ply, model)
	local allowed = IsAllowed(ply, BSU.PRIV_MODEL, model)
	if not allowed then
		NotifyRestricted(ply, string.match(model, "^models/.+%.mdl"))
		return false
	end
end

local function CheckNPCPrivilege(ply, npc)
	local allowed = IsAllowed(ply, BSU.PRIV_NPC, npc)
	if not allowed then
		NotifyRestricted(ply, npc)
		return false
	end
end

local function CheckSENTPrivilege(ply, ent)
	local allowed = IsAllowed(ply, BSU.PRIV_SENT, ent)
	if not allowed then
		NotifyRestricted(ply, ent)
		return false
	end
end

local function CheckSWEPPrivilege(ply, wep)
	local allowed = IsAllowed(ply, BSU.PRIV_SWEP, wep)
	if not allowed then
		NotifyRestricted(ply, wep)
		return false
	end
end

-- note: if the server cvar 'toolmode_allow_<tool>' is set to 0 then this doesn't get called
local function CheckToolPrivilege(ply, _, tool)
	local allowed = IsAllowed(ply, BSU.PRIV_TOOL, tool)
	if not allowed then
		NotifyRestricted(ply, tool)
		return false
	end
end

hook.Add("PlayerSpawnObject", "BSU_CheckModelPrivilege", CheckModelPrivilege)

hook.Add("PlayerSpawnVehicle", "BSU_CheckModelPrivilege", CheckModelPrivilege)

hook.Add("PlayerSpawnNPC", "BSU_CheckNPCPrivilege", CheckNPCPrivilege)

hook.Add("PlayerSpawnSENT", "BSU_CheckSENTPrivilege", CheckSENTPrivilege)

hook.Add("PlayerSpawnSWEP", "BSU_CheckSWEPPrivilege", CheckSWEPPrivilege)

hook.Add("PlayerGiveSWEP", "BSU_CheckSWEPPrivilege", CheckSWEPPrivilege)

hook.Add("CanTool", "BSU_CheckToolPrivilege", CheckToolPrivilege)
