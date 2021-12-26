-- base/server/privileges.lua

local function notifyRestricted(ply, msg)
  BSU.ClientRPC(ply, "notification.AddLegacy", "'" .. msg .. "' is restricted", NOTIFY_ERROR, 5)
end

local function checkModelPrivilege(ply, model)
  local allowed = BSU.IsPlayerAllowed(ply, BSU.PRIVILEGE_MODEL, model)
  if not allowed then
    notifyRestricted(ply, BSU.TrimModelPath(model))
    return false
  end
  return true
end

local function checkNPCPrivilege(ply, npc)
  local allowed = BSU.IsPlayerAllowed(ply, BSU.PRIVILEGE_NPC, npc)
  if not allowed then
    notifyRestricted(ply, npc)
    return false
  end
  return true
end

local function checkSENTPrivilege(ply, ent)
  local allowed = BSU.IsPlayerAllowed(ply, BSU.PRIVILEGE_SENT, ent)
  if not allowed then
    notifyRestricted(ply, ent)
    return false
  end
  return true
end

local function checkSWEPPrivilege(ply, wep)
  local allowed = BSU.IsPlayerAllowed(ply, BSU.PRIVILEGE_SWEP, wep)
  if not allowed then
    notifyRestricted(ply, wep)
    return false
  end
  return true
end

-- note: if the server cvar 'toolmode_allow_<tool>' is set to 0 then this doesn't get called
local function checkToolPrivilege(ply, _, tool)
  local allowed = BSU.IsPlayerAllowed(ply, BSU.PRIVILEGE_TOOL, tool)
  if not allowed then
    notifyRestricted(ply, tool)
    return false
  end
  return true
end

hook.Add("PlayerSpawnObject", "BSU_CheckModelPrivilege", checkModelPrivilege)

hook.Add("PlayerSpawnVehicle", "BSU_CheckModelPrivilege", checkModelPrivilege)

hook.Add("PlayerSpawnNPC", "BSU_CheckNPCPrivilege", checkNPCPrivilege)

hook.Add("PlayerSpawnSENT", "BSU_CheckSENTPrivilege", checkSENTPrivilege)

hook.Add("PlayerSpawnSWEP", "BSU_CheckSWEPPrivilege", checkSWEPPrivilege)

hook.Add("PlayerGiveSWEP", "BSU_CheckSWEPPrivilege", checkSWEPPrivilege)

hook.Add("CanTool", "BSU_CheckToolPrivilege", checkToolPrivilege)