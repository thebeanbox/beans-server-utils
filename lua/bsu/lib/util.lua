-- lib/util.lua (SHARED)
-- useful functions for both server and client

function BSU.Log(msg)
  MsgC(SERVER and Color(0, 100, 255) or Color(255, 100, 0), "[BSU] ", color_white, msg .. "\n")
end

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
  if not steamid then return false end
  return util.SteamIDTo64(steamid) ~= "0" or util.SteamIDFrom64(steamid) ~= "0"
end

-- checks if a string is a valid ip address (valid excluding the port)
function BSU.IsValidIP(ip)
  if not ip then return false end
  local address, port = unpack(string.Split(":"))
  return string.find(address, "^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?$") ~= nil and not port or string.find(port, "^%d%d?%d?%d?%d?$")
end

-- tries to convert a steamid to 64 bit if it's valid
function BSU.ID64(steamid)
  if not BSU.IsValidSteamID(steamid) then return error("Received invalid Steam ID (" .. steamid .. ")!") end
  local id64 = util.SteamIDTo64(steamid)
  return id64 ~= "0" and id64 or steamid
end

-- removes port from ip if it's valid
function BSU.Address(ip)
  if not BSU.IsValidIP(ip) then return error("Received invalid IP address (" .. ip .. ")!") end
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