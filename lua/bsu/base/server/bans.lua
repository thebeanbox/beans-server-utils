-- base/server/bans.lua
-- handles player bans

-- check if player is banned and prevent them from joining when attempting to connect
local function passwordBanCheck(steamid, ip)
  local success, callback, reason = xpcall(
    function()
      local ban = BSU.GetBanStatus(steamid) -- check for any bans on the steam id
      if not ban then
        ban = BSU.GetBanStatus(ip) -- check for any bans on the ip
      end
      if ban then
        return false, BSU.FormatBanMsg(ban.reason, ban.duration, ban.time)
      end
    end,
    function(err)
      return err
    end
  )
  
  -- if for some reason an error occurs while getting the ban data, then kick the client just to be safe (this should hopefully never happen)
  -- without this a banned player will be able to join if an error occurs
  if success then
    return callback, reason
  else
    steamid = util.SteamIDFrom64(steamid)
    MsgN("Error while ban checking client (" .. steamid .. "): " .. callback)
    return false, "Oops! Something bad happened...\n\nWe encountered an error while authenticating you:\n\n" .. callback .. "\n\nKicking the client (" .. steamid .. ") just to be safe."
  end
end

hook.Add("CheckPassword", "BSU_PasswordBanCheck", passwordBanCheck)

-- permaban players using family share to ban evade (also kicks players who are banned but somehow joined the server)
local function authedBanCheck(ply)
  local plyID = ply:SteamID64()

  local plyBan = BSU.GetBanStatus(plyID)
  if plyBan then -- if player is banned
    game.KickID(ply:UserID(), "(Banned) " .. (plyBan.reason or "No reason given")) -- silently kick (don't need this added to the db)
  else
    local ownerID = ply:OwnerSteamID64()
    if plyID ~= ownerID then -- this player doesn't own the Garry's Mod license they're using
      local ownerBan = BSU.GetBanStatus(ownerID)
      if ownerBan then -- if the owner of the license is banned
        -- "if you have the audacity to try and ban evade you can enjoy a permaban" -Bonyoze
        BSU.BanPlayer(ply, string.format("%s (Family share with banned account: %s)", ownerBan.reason or "No reason given", util.SteamIDFrom64(ownerID)), 0, ownerBan.reason)
      end
    end
  end
end

hook.Add("PlayerAuthed", "BSU_AuthedBanCheck", authedBanCheck)
