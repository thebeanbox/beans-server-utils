-- base/server/bans.lua
-- handles player bans

-- check if player is banned when attempting to connect
local function banCheck(steamid, ip)
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

hook.Add("CheckPassword", "BSU_BanCheck", banCheck)

local function familyShareCheck(ply)
  local steam64 = ply:OwnerSteamID64()
  local ban = BSU.GetBanStatus(steam64)

  if ban then
    local steamID = util.SteamIDFrom64(steam64)
    BSU.BanSteamID(
      ply:SteamID64(),
      string.format("Family Share With Banned Account (%s) (%s)", steamID, ban.reason),
      ban.duration==0 and 0 or (ban.duration - math.ceil((BSU.UTCTime() - ban.time) / 60))
    )
  end
end

hook.Add("PlayerAuthed", "BSU_FamilyShareCheck", familyShareCheck)
