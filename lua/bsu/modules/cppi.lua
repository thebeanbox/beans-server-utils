--[[
  CPPI for external addons to interface with the prop protection
  
  https://ulyssesmod.net/archive/CPPI_v1-3.pdf
]]

local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

CPPI = {}
CPPI_NOTIMPLEMENTED = 0
CPPI_DEFERRED = 1

function CPPI:GetName()
  return "BSU"
end

function CPPI:GetVersion()
  return "1.0"
end

function CPPI:GetInterfaceVersion()
  return 1.3
end

function entMeta:CPPIGetOwner()
  local owner = BSU.GetEntityOwner(self)
  if IsValid(owner) then -- this also excludes stuff owned by the world because IsValid(game.GetWorld()) returns false
    return owner, CPPI_NOTIMPLEMENTED
  end
end

if SERVER then
  function plyMeta:CPPIGetFriends()
    local steamids = BSU.GetPlayerPermissionList(self:SteamID64(), BSU.PP_TOOLGUN)
    local lookup = {}
    for i = 1, #steamids do
      lookup[steamids[i]] = true
    end
    
    local players = player.GetAll()
    local friends = {}
    for _, ply in ipairs(players) do
      if ply:IsSuperAdmin() then
        table.insert(friends, ply)
      elseif lookup[ply:SteamID64()] then
        table.insert(friends, ply)
      end
    end
    
    return friends
  end

  function entMeta:CPPISetOwner(ply)
    if ply then
      BSU.SetEntityOwner(self, ply)
    else
      BSU.SetEntityOwnerless()
    end
    return true
  end

  function entMeta:CPPISetOwnerUID(uid)
    return CPPI_NOTIMPLEMENTED
  end

  function entMeta:CPPICanTool(ply, mode)
    return BSU.PlayerHasEntityPermission(ply, self, BSU.PP_TOOLGUN)
  end

  function entMeta:CPPICanPhysgun(ply)
    return BSU.PlayerHasEntityPermission(ply, self, BSU.PP_PHYSGUN)
  end

  function entMeta:CPPICanPickup(ply)
    return BSU.PlayerHasEntityPermission(ply, self, BSU.PP_PICKUP)
  end

  entMeta.CPPICanPunt = entMeta.CPPICanPickup

  function entMeta:CPPICanUse(ply)
    return BSU.PlayerHasEntityPermission(ply, self, BSU.PP_USE)
  end
  
  function entMeta:CPPICanDamage(ply)
    return BSU.PlayerHasEntityPermission(ply, self, BSU.PP_DAMAGE)
  end

  entMeta.CPPICanDrive = entMeta.CPPICanUse

  entMeta.CPPICanProperty = entMeta.CPPICanTool

  entMeta.CPPICanEditVariable = entMeta.CPPICanTool
else
  function plyMeta:CPPIGetFriends()
    return CPPI_NOTIMPLEMENTED
  end
end
