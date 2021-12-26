-- lib/server/bans.lua
-- functions for managing bans

function BSU.RegisterBan(identity, reason, duration, admin) -- this is also used for logging kicks (when duration = null)
  BSU.SQLInsert(BSU.SQL_BANS,
    {
      identity = identity,
      reason = reason,
      duration = duration,
      time = BSU.UTCTime(),
      admin = admin and BSU.ID64(admin)
    }
  )
end

function BSU.GetBansByValues(values)
  return BSU.SQLSelectByValues(BSU.SQL_BANS, values) or {}
end

-- returns data of the latest ban if they are still banned, otherwise nothing if they aren't currently banned (can take a steam id or ip address)
function BSU.GetBanStatus(identity)
  -- correct the argument (steam id to 64 bit) (removing port from ip address)
  identity = BSU.IsValidSteamID(identity) and BSU.ID64(identity) or BSU.IsValidIP(identity) and BSU.RemovePort(identity)

  local bans = BSU.GetBansByValues({ identity = identity })
  
  for k, v in ipairs(bans) do -- exclude kicks
    if not v.duration then table.remove(bans, k) end
  end
  
  if #bans > 0 then
    table.sort(bans, function(a, b) return a.time > b.time end) -- sort from latest to oldest

    local latestBan = bans[1]
    
    if latestBan.duration == 0 or (latestBan.time + latestBan.duration * 60) > BSU.UTCTime() then -- this guy is perma'd or still banned
      return latestBan
    end
  end
end

function BSU.BanSteamID(id, reason, duration, adminID)
  id = BSU.ID64(id)
  if adminID then adminID = BSU.ID64(adminID) end

  BSU.RegisterBan(id, reason, duration or 0, adminID)

  for k, v in ipairs(player.GetHumans()) do -- try to kick the player
    if v:SteamID64() == id then
      v:Kick("(Banned) " .. reason)
      break
    end
  end
end

function BSU.BanIP(ip, reason, duration, adminID)
  ip = BSU.RemovePort(ip)
  if adminID then adminID = BSU.ID64(adminID) end

  BSU.RegisterBan(ip, reason, duration or 0, adminID)

  for k, v in ipairs(player.GetHumans()) do -- try to kick all players with this ip
    if BSU.RemovePort(v:IPAddress()) == ip then
      v:Kick("(Banned) " .. reason)
    end
  end
end

function BSU.BanPlayer(ply, reason, duration, admin)
  if ply:IsBot() then return error("Unable to ban a bot!") end
  BSU.BanSteamID(ply:SteamID64(), reason, duration, (admin and admin:IsValid()) and admin:SteamID64())
end

function BSU.IPBanPlayer(ply, reason, duration, admin)
  if ply:IsBot() then return error("Unable to ban a bot!") end
  BSU.BanIP(ply:IPAddress(), reason, duration, (admin and admin:IsValid()) and admin:SteamID64())
end

function BSU.KickPlayer(ply, reason, admin)
  ply:Kick("(Kicked) " .. reason)
  BSU.RegisterBan(ply:SteamID64(), reason, nil, (admin and admin:IsValid()) and admin:SteamID64()) -- log it
end

function BSU.FormatBanMsg(reason, duration, time)
  return string.gsub(BSU.BAN_MSG, "%%([%w_]+)%%",
    {
      reason = reason or "(None given)",
      duration = duration == 0 and "(Permaban)" or BSU.StringTime(duration * 60),
      remaining = duration == 0 and "(Permaban)" or BSU.StringTime(time + duration * 60 - BSU.UTCTime()),
      time = os.date("%a, %b %d, %Y - %I:%M:%S %p (GMT)", time) .. " (" .. (BSU.UTCTime() - time < 60 and "A few seconds ago" or BSU.StringTime(BSU.UTCTime() - time - 60) .. " ago") .. ")"
    }
  )
end