--[[
  CPPI for external addons to interface with the prop protection
  
  https://ulyssesmod.net/archive/CPPI_v1-3.pdf
]]
local PP = BSU.PropProtection

CPPI = {}
CPPI_NOTIMPLEMENTED = 26
CPPI_DEFERRED = 16

function CPPI:GetName()
  return "BSU Prop Protection"
end

function CPPI:GetVersion()
  return "1.0"
end

function CPPI:GetInterfaceVersion()
  return 1.3
end

function CPPI:GetNameFromUID(uid)
  return CPPI_NOTIMPLEMENTED
end

local plymeta = FindMetaTable("Player")
if not plymeta then error("Unable to get player metatable") end

function plymeta:CPPIGetFriends()
  local steamids = PP.Players[self:SteamID()]["toolgun"]

  local players = {}
  for k,v in pairs(player.GetAll()) do
    if steamids[v:SteamID()] then
      table.insert(players, v)
    end
  end

  return players
end

local entmeta = FindMetaTable("Entity")
if not entmeta then error("Unable to get entity metatable") end

function entmeta:CPPIGetOwner()
  return PP.GetOwner(self),CPPI_NOTIMPLEMENTED
end

if SERVER then
  function entmeta:CPPISetOwner(ply)
    return PP.SetOwner(ent, ply)
  end

  function entmeta:CPPISetOwnerUID(uid)
    return CPPI_NOTIMPLEMENTED
  end

  function entmeta:CPPICanTool(ply, mode)
    local owner = PP.GetOwner(self)
    if owner==ply or not owner then return true end

    return PP.HasPerm(ply, owner, "toolgun") or false --Change nil to false
  end

  function entmeta:CPPICanPhysgun(ply)
    local owner = PP.GetOwner(self)
    if owner==ply or not owner then return true end

    return PP.HasPerm(ply, owner, "physgun") or false --Change nil to false
  end

  function entmeta:CPPICanPickup(ply)
    local owner = PP.GetOwner(self)
    if owner==ply or not owner then return true end

    return PP.HasPerm(ply, owner, "gravgun") or false --Change nil to false
  end
  entmeta.CPPICanPunt = entmeta.CPPICanPickup

  function entmeta:CPPICanUse(ply)
    local owner = PP.GetOwner(self)
    if owner==ply or not owner then return true end

    return PP.HasPerm(ply, owner, "use") or false --Change nil to false
  end
  entmeta.CPPIDrive = entmeta.CPPICanUse

  entmeta.CPPICanProperty = entmeta.CPPICanTool
  entmeta.CPPICanEditVariable = entmeta.CPPICanTool
end

local function CPPIInitGM()
	function GAMEMODE:CPPIAssignOwnership(ply, ent)
	end
	function GAMEMODE:CPPIFriendsChanged(ply, ent)
	end
end
hook.Add("Initialize", "CPPIInitGM", CPPIInitGM)
