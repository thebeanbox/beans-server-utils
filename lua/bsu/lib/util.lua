-- lib/util.lua (SHARED)
-- useful functions for both server and client

function BSU.ColorToHex(color)
  return string.format("%.2x%.2x%.2x", color.r, color.g, color.b)
end

function BSU.HexToColor(hex, alpha)
  hex = string.gsub(hex, "#", "")
  return Color(tonumber("0x" .. hex:sub(1,2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6)), alpha or 255)
end

function BSU.UTCTime()
  return os.time(os.date("!*t"))
end

-- checks if a string is in either the STEAM_0 or 64 bit format
function BSU.IsValidSteamID(steamid)
  return util.SteamIDTo64(steamid) ~= "0" or util.SteamIDFrom64(steamid) ~= "0"
end

-- checks if a string is a valid ip address (valid excluding the port)
function BSU.IsValidIP(ip)
  return string.find(ip, "^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?$") ~= nil
end

-- tries to convert a steamid to 64 bit
function BSU.ID64(steamid)
  if not BSU.IsValidSteamID(steamid) then return error("Received invalid Steam ID (" .. steamid .. ")!") end
  local id64 = util.SteamIDTo64(steamid)
  return id64 ~= "0" and id64 or steamid
end

function BSU.RemovePort(ip)
  return string.Split(ip, ":")[1]
end

function BSU.StringTime(secs)
  local mins = math.ceil(secs / 60)
  local strs = {}
  local timesInMins = {
    { "year", 525600 },
    { "week", 10080 },
    { "day", 1440 },
    { "hour", 60 },
    { "minute", 1 }
  }

  for i = 1, #timesInMins do
    local time, len = unpack(timesInMins[i])

    if mins >= len then
      local timeConvert = math.floor(mins / len)
      mins = mins % len
      table.insert(strs, string.format("%i %s%s", timeConvert, time, timeConvert > 1 and "s" or ""))
    end
  end

  return #strs > 1 and (table.concat(strs, ", ", 1, #strs - 1) .. " and " .. strs[#strs]) or strs[1]
end

-- given a string, finds a var from the global namespace (thanks ULib)
function BSU.FindVar(location, root)
  root = root or _G

  local tableCrumbs = string.Explode("[%.%[]", location, true)
  for i = 1, #tableCrumbs do
    local new, replaced = string.gsub(tableCrumbs[i], "]$", "")
    if replaced > 0 then tableCrumbs[i] = (tonumber(new) or new) end
  end

  -- navigating
  for i = 1, #tableCrumbs - 1 do
    root = root[tableCrumbs[i]]
    if not root or type(root) ~= "table" then return end
  end

  return root[tableCrumbs[#tableCrumbs]]
end

function BSU.TrimModelPath(model)
  return string.match(model, "models/(.-).mdl") or model
end