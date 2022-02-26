-- lib/server/bans.lua
-- functions for managing bans

function BSU.RegisterBan(identity, reason, duration, admin) -- this is also used for logging kicks (when duration = null)
  BSU.SQLInsert(BSU.SQL_BANS, {
    identity = identity,
    reason = reason,
    duration = duration,
    time = BSU.UTCTime(),
    admin = admin and BSU.ID64(admin)
  })
end

function BSU.GetAllBans()
  return BSU.SQLSelectAll(BSU.SQL_BANS)
end

function BSU.GetBansByValues(values)
  return BSU.SQLSelectByValues(BSU.SQL_BANS, values)
end

-- returns data of the latest ban if they are still banned, otherwise nothing if they aren't currently banned (can take a steam id or ip address)
function BSU.GetBanStatus(identity)
  -- correct the argument (steam id to 64 bit) (removing port from ip address)
  identity = BSU.IsValidSteamID(identity) and BSU.ID64(identity) or BSU.IsValidIP(identity) and BSU.RemovePort(identity)

  local bans = {}
  for k, v in ipairs(BSU.GetBansByValues({ identity = identity })) do -- exclude kicks since they're also logged
    if v.duration then table.insert(bans, v) end
  end
  
  if #bans > 0 then
    table.sort(bans, function(a, b) return a.time > b.time end) -- sort from latest to oldest

    local latestBan = bans[1]
    
    if not latestBan.unbanTime and (latestBan.duration == 0 or (latestBan.time + latestBan.duration * 60) > BSU.UTCTime()) then -- this guy is perma'd or still banned
      return latestBan
    end
  end
end

-- ban a player by steam id (this adds a new ban entry so it will be the new ban status for this player)
function BSU.BanSteamID(steamid, reason, duration, adminID)
  steamid = BSU.ID64(steamid)
  if adminID then adminID = BSU.ID64(adminID) end

  BSU.RegisterBan(steamid, reason, duration or 0, adminID and BSU.ID64(adminID))

  game.KickID(util.SteamIDFrom64(steamid), "(Banned) " .. (reason or "No reason given"))
end

-- ban a player by ip (this adds a new ban entry so it will be the new ban status for this player)
function BSU.BanIP(ip, reason, duration, adminID)
  ip = BSU.RemovePort(ip)

  BSU.RegisterBan(ip, reason, duration or 0, adminID and BSU.ID64(adminID))

  for k, v in ipairs(player.GetHumans()) do -- try to kick all players with this ip
    if BSU.RemovePort(v:IPAddress()) == ip then
      game.KickID(v:UserID(), "(Banned) " .. (reason or "No reason given"))
    end
  end
end

-- unban a player by steam id
function BSU.RevokeSteamIDBan(steamid, adminID)
  local lastBan = BSU.GetBanStatus(steamid)
  if not lastBan then return error("Steam ID is not currently banned") end

  BSU.SQLUpdateByValues(BSU.SQL_BANS, lastBan, { unbanTime = BSU.UTCTime(), unbanAdmin = adminID and BSU.ID64(adminID) })
end

-- unban a player by ip
function BSU.RevokeIPBan(ip, adminID)
  local lastBan = BSU.GetBanStatus(ip)
  if not lastBan then return error("IP is not currently banned") end
  
  BSU.SQLUpdateByValues(BSU.SQL_BANS, lastBan, { unbanTime = BSU.UTCTime(), unbanAdmin = adminID and BSU.ID64(adminID) })
end

function BSU.BanPlayer(ply, reason, duration, admin)
  if ply:IsBot() then return error("Unable to ban a bot") end
  BSU.BanSteamID(ply:SteamID64(), reason, duration, (admin and admin:IsValid()) and admin:SteamID64())
end

function BSU.SuperBanPlayer(ply, reason, duration, admin)
  BSU.BanPlayer(ply, reason, duration, admin)

  if ply:IsFullyAuthenticated() and ply:OwnerSteamID64() ~= ply:SteamID64() then
    BSU.BanSteamID(ply:OwnerSteamID64(), reason, duration, (admin and admin:IsValid()) and admin:SteamID64())
  end
end

function BSU.SuperDuperBanPlayer(ply, reason, duration, admin)
  BSU.SuperBanPlayer(ply, reason, duration, admin)
  BSU.IPBanPlayer(ply, reason, duration, admin)
end

function BSU.IPBanPlayer(ply, reason, duration, admin)
  if ply:IsBot() then return error("Unable to ban a bot!") end
  BSU.BanIP(ply:IPAddress(), reason, duration, (admin and admin:IsValid()) and admin:SteamID64())
end

function BSU.KickPlayer(ply, reason, admin)
  game.KickID(ply:UserID(), "(Kicked) " .. (reason or "No reason given"))
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