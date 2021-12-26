--[[
  Prop Protection script for The BeanBox

  Most of this is based on SimplePropProtection by Spacetech, which is currently being maintained by Donkie.
  https://github.com/Donkie/SimplePropProtection
]]

local PP = BSU.PropProtection

--Setup World Props
timer.Simple(10, function()
  for _, ent in pairs(ents.FindByClass("*")) do
    if not ent:IsPlayer() and not ent:GetNWString("Owner", false) then
      PP.Props[ent:EntIndex()] = {
        Ent = ent,
        Owner = game.GetWorld(),
      }

      ent:SetNWString("Owner", "World")
      ent:SetNWEntity("OwnerEnt", game.GetWorld())
    end
  end
end)

hook.Add("PlayerInitialSpawn", "PP_InitPlayer", PP.InitPlayer)

local function PP_PlayerDisconnected(ply)
  PP.Players[ply:SteamID()] = nil
end

hook.Add("PlayerDisconnected", "PP_PlayerDisconnected", PP_PlayerDisconnected)

if cleanup then
  local Clean = cleanup.Add
  function cleanup.Add(ply, Type, ent)
    if ent then
      if ply:IsPlayer() and IsValid(ent) then
        PP.SetOwner(ent, ply)
      end
    end
    Clean(ply, Type, ent)
  end
end

local metaply = FindMetaTable("Player")
hook.Add("Initialize","BSU_AddCount_Iinit",function()
  if metaply.AddCount then
    local backupAddCount = metaply.AddCount
    function metaply:AddCount(enttype, ent)
      PP.SetOwner(ent, self)
      backupAddCount(self, enttype, ent)
    end
  end
end)

hook.Add("EntityRemoved", "PP_EntityRemoved", function(ent)
  PP.Props[ent:EntIndex()] = nil
end)

local function PP_Physgun(ply, ent)
  if not IsValid(ent) then return end

  if ply:IsSuperAdmin() then return true end

  local owner = PP.GetOwner(ent)
  if owner == game.GetWorld() then return false end

  if not owner then
    if ent:IsPlayer() then
      if PP.HasPerm(ply, ent, "playerpickup") then
        return true
      end
    else
      PP.SetOwner(ent, ply)
      return true
    end

    return false
  end

  if not PP.Players[owner:SteamID()] then
    PP.InitPlayer(owner)
  end

  if owner == ply or PP.HasPerm(ply, owner, "physgun") then
    return true
  end

  return false
end

hook.Add("PhysgunPickup", "BSU_PropProtectPhysgun", PP_Physgun)

local function PP_GravGun(ply, ent)
  if not IsValid(ent) or ent:IsPlayer() then return end

  if ply:IsSuperAdmin() then return true end

  local owner = PP.GetOwner(ent)
  if owner == game.GetWorld() then return true end

  if not owner then
    PP.SetOwner(ent, ply)
    return true
  end

  if not PP.Players[owner:SteamID()] then
    PP.InitPlayer(owner)
  end

  if owner == ply or PP.HasPerm(ply, owner, "gravgun") then
    return true
  end

  return false
end

hook.Add("GravGunPunt", "BSU_PropProtectGravgun", PP_GravGun)
hook.Add("GravGunPickupAllowed", "BSU_PropProtectGravgun", PP_GravGun)

local function PP_CanTool(ply, tr, tool)
  local ent = tr.Entity

  if not IsValid(ent) or ent:IsPlayer() then return end

  if ply:IsSuperAdmin() then return true end

  local owner = PP.GetOwner(ent)
  if owner == game.GetWorld() then return false end

  if not owner then
    PP.SetOwner(ent, ply)
    return true
  end

  if not PP.Players[owner:SteamID()] then
    PP.InitPlayer(owner)
  end

  if owner == ply or PP.HasPerm(ply, owner, "toolgun") then
    return true
  end

  return false
end

hook.Add("CanTool", "BSU_PropProtectTool", PP_CanTool)
hook.Add("CanProperty", "BSU_PropProtectTool", PP_CanTool)

local function PP_Use(ply, ent)
  if not IsValid(ent) or ent:IsPlayer() then return end

  if ply:IsSuperAdmin() then return true end

  local owner = PP.GetOwner(ent)
  if owner == game.GetWorld() then return true end

  if not owner then
    PP.SetOwner(ent, ply)
    return true
  end

  if not PP.Players[owner:SteamID()] then
    PP.InitPlayer(owner)
  end

  if owner == ply or PP.HasPerm(ply, owner, "use") then
    return true
  end

  return false
end

hook.Add("PlayerUse", "BSU_PropProtectUse", PP_Use)

--Should probably move this somewhere else since it's not really related to prop protection
hook.Add("OnPhysgunPickup", "BSU_PlayerPhysgunPickup", function(ply, ent)
  if ent:IsPlayer() then
    ent:SetMoveType(MOVETYPE_NONE)
  end
end)
hook.Add("PhysgunDrop", "BSU_PlayerPhysgunDrop", function(ply, ent)
  if ent:IsPlayer() then
    ent:SetMoveType(MOVETYPE_WALK)
  end
end)
