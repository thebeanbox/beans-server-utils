BSU.PropProtection = {
  Permissions = {
    ["Physgun"] = {
      realName = "physgun",
      index = 1,
    },
    ["Gravgun"] = {
      realName = "gravgun",
      index = 2,
    },
    ["Toolgun"] = {
      realName = "toolgun",
      index = 3,
    },
    ["Use"] = {
      realName = "use",
      index = 4,
    },
    ["Player Pickup"] = {
      realName = "playerpickup",
      index = 5,
    }
  }
}

local PP = BSU.PropProtection

function PP.GetOwner(ent)
  --Return from prop table on server to avoid clientside scripts changing prop ownership
  if SERVER then
    local PropTbl = PP.Props[ent:EntIndex()]
    if not PropTbl then return nil end
    local owner = PropTbl.Owner
    return owner
  end

  return ent:GetNWEntity("OwnerEnt")
end

if SERVER then
  PP.Players = {}
  PP.Props = {}
  
  function PP.InitPlayer(ply)
    PP.Players[ply:SteamID()] = {}
    for _,v in pairs(PP.Permissions) do
      PP.Players[ply:SteamID()][v.realName] = {}
    end
  end

  function PP.RemoveOwner(ent)
    PP.Props[ent:EntIndex()] = nil

    ent:SetNWString("Owner", nil)
    ent:SetNWEntity("OwnerEnt", nil)
  end

  function PP.SetOwner(ent, ply)
    if ent:IsPlayer() then
      return false
    end

    if not IsValid(ply) then
      PP.Props[ent:EntIndex()] = nil
      return
    end

    PP.Props[ent:EntIndex()] = {
      Ent = ent,
      Owner = ply,
    }

    ent:SetNWString("Owner", ply:Nick())
    ent:SetNWEntity("OwnerEnt", ply)
  end

  local function tableConcatKeys(tbl, sep)
    local str = ""
    for k,v in pairs(tbl) do
      str = str .. k .. sep
    end
    return str
  end

  function PP.AddPerm(plyG, plyR, perm) --Permission giver, Permission receiver, Permission name
    if not PP.Players[plyG:SteamID()] then
      PP.InitPlayer(plyG)
    end

    if not PP.Players[plyG:SteamID()][perm] then
      PP.Players[plyG:SteamID()][perm] = {}
    end

    plyG:SetNWString(perm, tableConcatKeys(PP.Players[plyG:SteamID()][perm],","))

    PP.Players[plyG:SteamID()][perm][plyR:SteamID()] = true
  end

  function PP.RemovePerm(plyG, plyR, perm) --Permission giver, Permission receiver, Permission name
    if not PP.Players[plyG:SteamID()] then
      PP.InitPlayer(plyG)
    end

    if not PP.Players[plyG:SteamID()][perm] then
      PP.Players[plyG:SteamID()][perm] = {}
    end

    plyG:SetNWString(perm, tableConcatKeys(PP.Players[plyG:SteamID()][perm],","))

    PP.Players[plyG:SteamID()][perm][plyR:SteamID()] = nil
  end

  function PP.HasPerm(plyT, plyC, perm) --Does plyT Player have perm Permission on plyC? Returns nil on false
    if not PP.Players[plyC:SteamID()] then
      PP.InitPlayer(plyC)
    end

    if not PP.Players[plyC:SteamID()][perm] then
      PP.Players[plyC:SteamID()][perm] = {}
    end
    
    return PP.Players[plyC:SteamID()][perm][plyT:SteamID()]
  end
end
