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
    
    local players = player.GetAll()
    local friends = {}
    for _, ply in ipairs(players) do
      if ply:IsSuperAdmin() then
        table.insert(friends, ply)
        table.remove(steamids, k)
      else
        for k, id in ipairs(steamids) do
          if ply:SteamID64() == id then
            table.insert(friends, ply)
            table.remove(steamids, k)
            break
          end
        end
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

  function entMeta:CPPICanPunt(ply)
    return self:CPPICanPickup(ply)
  end

  function entMeta:CPPICanUse(ply)
    return BSU.PlayerHasEntityPermission(ply, self, BSU.PP_USE)
  end
  
  function entMeta:CPPICanDamage(ply)
    return BSU.PlayerHasEntityPermission(ply, self, BSU.PP_DAMAGE)
  end

  function entMeta:CPPICanDrive(ply)
    return self:CPPICanUse(ply)
  end

  function entMeta:CPPICanProperty(ply)
    return self:CPPICanTool(ply)
  end

  function entMeta:CPPICanEditVariable(ply)
    return self:CPPICanTool(ply)
  end
else
  function plyMeta:CPPIGetFriends()
    return CPPI_NOTIMPLEMENTED
  end
end
