-- lib/server/commands.lua

local groupChars = {
  '"',
  "'"
}

-- parse a string to command arguments (set inclusive to true to leave the group chars in the result)
local function parseArgs(input, inclusive)
  local index, args = 1, {}

  while true do
    local str = string.sub(input, index)

    -- look for group chars
    local foundGroupChars = {}
    for i = 1, #groupChars do
      local char = groupChars[i]
      local pos = string.find(str, char, 1, true)
      if pos then
        table.insert(foundGroupChars, { char, pos })
      end
    end

    local found

    if not table.IsEmpty(foundGroupChars) then
      table.sort(foundGroupChars, function(a, b) return a[2] < b[2] end)

      for i = 1, #foundGroupChars do
        local char, pos1 = unpack(foundGroupChars[i])
        local pos2 = string.find(str, char, pos1 + 1, true)
        if pos2 then
          -- add before args separated by spaces
          local split = string.Split(string.sub(str, 1, pos1 - 1), " ")
          if args[#args] then
            args[#args] = args[#args] .. table.remove(split, 1) -- append first string to last arg
          end
          table.Add(args, split) -- add the rest

          args[#args] = args[#args] .. string.sub(str, pos1 + (inclusive and 0 or 1), pos2 - (inclusive and 0 or 1)) -- append string to last arg
          index = index + pos2
          found = true
          break
        end
      end
    end

    if found then continue end

    -- add args separated by spaces
    local split = string.Split(str, " ")
    if args[#args] then
      args[#args] = args[#args] .. table.remove(split, 1) -- append first string to last arg
    end
    table.Add(args, split) -- add the rest
    break
  end

  -- remove any empty string args
  local newArgs = {}
  for i = 1, #args do
    local arg = args[i]
    if arg ~= "" then
      table.insert(newArgs, arg)
    end
  end

  return newArgs
end

-- returns table of players via prefixed command argument
-- returns nil if failed to retrieve (ex: invalid player name, invalid player steamid, invalid group name, or no prefixes matched)
local function parsePlayerArg(user, str)
  if str == "^" then -- player who ran the command
    return { user }
  elseif str == "*" then -- wildcard (all players)
    return player.GetAll()
  else
    local pre = string.sub(str, 1, 1)
    local val = string.sub(str, 2)
    if pre == "@" then -- specific player
      val = parseArgs(val)[1]
      if val then -- get by player name
        val = string.lower(val)
        for _, v in ipairs(player.GetAll()) do
          if val == string.lower(v:GetName()) then
            return { v }
          end
        end
      elseif user:IsValid() then -- get by eye trace
        local ent = user:GetEyeTrace().Entity
        if ent:IsPlayer() then
          return { ent }
        end
      end
      return {}
    elseif pre == "$" then -- player by steamid
      val = parseArgs(val)[1]
      if BSU.IsValidSteamID(val) then
        local ply = player.GetBySteamID64(BSU.ID64(val))
        if ply ~= false and ply:IsValid() then
          return { ply }
        end
        return {}
      end
    elseif pre == "#" then -- players by exact group name (will include all players in all groups of same name)
      val = parseArgs(val)[1]

      local name, plys = string.lower(val), {}

      for _, v in ipairs(BSU.GetAllGroups()) do
        if string.lower(v.name) == name then
          for _, vv in ipairs(team.GetPlayers(v.id)) do
            if not plys[vv] then -- use a lookup table to prevent duplicate players
              plys[vv] = true
            end
          end
        end
      end

      return table.GetKeys(plys)
    elseif pre == "!" then -- opposite of next prefix
      local result = parsePlayerArg(user, val)
      
      -- create lookup table from result
      local list = {}
      for i = 1, #result do
        list[result[i]] = true
      end

      -- get all players not in the lookup table
      local plys = {}
      for _, v in ipairs(player.GetAll()) do
        if not list[v] then
          table.insert(plys, v)
        end
      end

      return plys
    end
  end

  -- check if the argument matches player names
  local nameArg, plys = string.lower(parseArgs(str)[1]), {}

  for _, v in ipairs(player.GetAll()) do
    local name = string.lower(v:GetName())
    if nameArg == name then -- found exact name
      return { v }
    elseif #nameArg >= 3 then -- must be a minimum of 3 characters for partial search
      if string.find(name, nameArg, 1, true) then
        table.insert(plys, v)
      end
    end
  end

  return plys
end

local cmds = {}
local _tempUser, _tempArgs

-- command object
local objCommand = {}
objCommand.__index = objCommand
objCommand.__tostring = function(self) return "BSU Command[" .. self.name .. "]" end

function objCommand.GetCommandName(self)
  return self.name
end

function objCommand.GetCommandDescription(self)
  return self.description
end

function objCommand.GetCommandAccess(self)
  return self.access
end

local function errorBadArgument(num, reason)
  error("bad argument #" .. num .. " (" .. reason .. ")")
end

-- used for getting the original string of the argument
function objCommand.GetRawString(self, n, check)
  local arg = _tempArgs[n]
  if arg then
    return arg
  elseif check then
    errorBadArgument(n, "expected string, found nothing")
  end
end

-- used for getting the string of the argument but parsed
function objCommand.GetString(self, n, check)
  local str = self:GetRawString(n, check)
  if str then
    return parseArgs(str)[1]
  elseif check then
    errorBadArgument(n, "expected string, found nothing")
  end
end

-- used for getting multiple original string arguments as a single string
function objCommand.GetRawMultiString(self, n1, n2, check)
  if n1 < 0 then
    n1 = #_tempArgs + n1 + 1
  end
  if n2 then
    if n2 < 0 then
      n2 = #_tempArgs + n2 + 1
    end
  else
    n2 = #_tempArgs
  end

  if n1 ~= n2 then -- get unparsed arguments from n1 to n2
    local str
    for i = n1, n2 do
      local arg = _tempArgs[i]
      if arg then
        if not str then
          str = arg
        else
          str = str .. " " .. arg
        end
      else
        break
      end
    end
    if str then
      return str
    elseif check then
      errorBadArgument(n1, "expected string, found nothing")
    end
  end
  local arg = _tempArgs[n1]
  if arg then
    return arg
  elseif check then
    errorBadArgument(n1, "expected string, found nothing")
  end
end

-- used for getting multiple parsed string arguments as a single string
function objCommand.GetMultiString(self, n1, n2, check)
  local str = self:GetRawMultiString(n1, n2, check)
  if str then
    return table.concat(parseArgs(str), " ") -- parse and concat back to string
  elseif check then
    errorBadArgument(n1, "expected string, found nothing")
  end
end

-- used for getting an argument parsed as a number (will fail if it couldn't be converted to a number)
function objCommand.GetNumber(self, n, check)
  local arg = _tempArgs[n]
  if arg then
    local val = tonumber(arg)
    if val then
      return val
    elseif check then
      errorBadArgument(n, "failed to interpret '" .. arg .. "' as a number")
    end
  elseif check then
    errorBadArgument(n, "expected number, got nothing")
  end
end

-- used for getting an argument parsed as a target (will fail if none or more than 1 targets are found)
function objCommand.GetPlayer(self, n, check)
  local arg = _tempArgs[n]
  if arg then
    local plys = parsePlayerArg(_tempUser, arg)
    if #plys == 1 then
      local ply = plys[1]
      if ply:IsValid() then
        return ply
      elseif check then
        errorBadArgument(n, "target was invalid")
      end
    elseif check then
      if table.IsEmpty(plys) then
        errorBadArgument(n, "failed to find a target")
      else
        errorBadArgument(n, "received too many targets")
      end
    end
  elseif check then
    errorBadArgument(n, "expected target, found nothing")
  end
end

-- used for getting an argument parsed as 1 or more targets (will fail if none are found)
function objCommand.GetPlayers(self, n, check)
  local arg = _tempArgs[n]
  if arg then
    local plys = parsePlayerArg(_tempUser, arg)
    if not table.IsEmpty(plys) then
      return plys
    elseif check then
      errorBadArgument(n, "failed to find any targets")
    end
  elseif check then
    errorBadArgument(n, "expected targets, found nothing")
  end
end

-- sends a message to a player in console (will print into the server console if the command was ran through it)
function objCommand.SendConMsg(self, ...)
  if _tempUser:IsValid() then
    BSU.SendConMsg(_tempUser, ...)
  else -- cmd was ran through the server console
    MsgC(...)
    MsgN()
  end
end

-- sends a message to a player in chat (will print into the server console if the command was ran through it)
function objCommand.SendChatMsg(self, ...)
  if _tempUser:IsValid() then -- cmd was ran through the server console
    BSU.SendChatMsg(_tempUser, ...)
  else -- cmd was ran through the server console
    MsgC(...)
    MsgN()
  end
end

-- some color values
local textClr = Color(151, 211, 255) -- normal text                             (light blue)
local paramClr = Color(0, 255, 0) -- when a parameter isn't an entity           (green)
local selfClr = Color(75, 0, 130) -- when target is client                      (dark purple)
local everyoneClr = Color(0, 130, 130) -- when targeting all plys on the server (cyan)
local consoleClr = Color(0, 0, 0) -- server console name                        (black)
local miscClr = Color(255, 255, 255) -- other (just used for non-player ents)   (white)

local function formatActionMsg(ply, target, msg, args)
  args = istable(args) and args or { args }
  local i, pos, vars = 1, 1, {}
  for str, obj in string.gmatch(msg, "(.-)%%(%w+)%%") do
    table.Add(vars, { textClr, str })

    obj = string.lower(obj)
    local arg
    while not arg and i <= #args do
      arg = args[i]
      i = i + 1
    end

    if arg then
      if obj == "user" then
        if arg:IsValid() then
          table.Add(vars, arg == target and { selfClr, "You" } or { team.GetColor(arg:Team()), arg:Nick() })
        else
          table.Add(vars, { consoleClr, "(Console)" })
        end
      elseif obj == "param" then
        local params = istable(arg) and arg or { arg }

        local isAllPlayers = true
        for k, v in ipairs(params) do
          if not v or not (IsEntity(v) and v:IsPlayer()) then
            isAllPlayers = false
            break
          end
        end

        if isAllPlayers and #params > 1 and #params == #player.GetAll() then
          table.Add(vars, { everyoneClr, "Everyone" })
        else
          for ii = 1, #params do
            local p = params[ii]

            if ii > 1 then
              table.Add(vars, { textClr, ii < #params and ", " or (#params > 2 and ", and " or " and ") })
            end

            if IsEntity(p) then
              if p:IsPlayer() then
                table.Add(vars, ply == p and (ply == target and { selfClr, "Yourself" } or { selfClr, "Themself" }) or { team.GetColor(p:Team()), p:Nick() })
              else
                table.Add(vars, { miscClr, tostring(p) })
              end
            else
              table.Add(vars, { paramClr, tostring(p) })
            end
          end
        end
      end
    end

    pos = pos + #str + #obj + 2
  end

  local last = string.sub(msg, pos)
  if #last > 0 then
    table.Add(vars, { textClr, last })
  end

  return unpack(vars)
end

-- sends a message in everyone's chat and formats player entities and tables of player entities
function objCommand.BroadcastActionMsg(self, msg, ...)
  local targets = player.GetHumans()
  table.insert(targets, 1, NULL)
  for k, v in ipairs(targets) do
    BSU.SendChatMsg(v, formatActionMsg(_tempUser, v, msg, ...))
  end
end

-- create a command object
function BSU.Command(name, desc, access, func)
  return setmetatable({
    name = string.lower(name), -- name of the command
    desc = desc or "", -- description of the command
    access = access or BSU.CMD_ANYONE, -- acessibility of the command (default: anyone can use the command)
    func = func -- function to be called when executing the command
  }, objCommand)
end

-- create a new command
-- (by default the command is accessible to anybody)
-- (making a command with the same name as a previously created command will override it and case doesn't matter) 
function BSU.CreateCommand(name, desc, access, func)
  if not isstring(name) then return error("Command must have a valid name") end
  if name ~= string.match(name, "%w+") then return error("Command name must only contain alphanumeric characters") end
  if not isfunction(func) then return error("Command must have a valid function") end
  cmds[string.lower(name)] = BSU.Command(name, desc, access, func)
end

function BSU.GetCommandByName(name)
  return cmds[string.lower(name)]
end

function BSU.GetCommandsByAccess(access)
  local list = {}
  for k, v in pairs(cmds) do
    if v.access == access then
      table.insert(list, v)
    end
  end
  return list
end

-- set whether a group must or mustn't have access to a command
-- (setting this will ignore the command's access value)
-- (access is granted by default)
function BSU.AddGroupCommandAccess(groupid, cmd, access)
  BSU.RegisterGroupPrivilege(groupid, BSU.PRIV_CMD, string.lower(cmd), access == nil and true or access)
end

-- set whether a player must or mustn't have access to a command
-- (setting this will ignore the command's access value)
-- (access is granted by default)
function BSU.AddPlayerCommandAccess(steamid, cmd, access)
  BSU.RegisterPlayerPrivilege(steamid, BSU.PRIV_CMD, string.lower(cmd), access == nil and true or access)
end

function BSU.RemoveGroupCommandAccess(groupid, cmd, access)
  BSU.RemoveGroupPrivilege(groupid, BSU.PRIV_CMD, string.lower(cmd))
end

function BSU.RemovePlayerCommandAccess(steamid, cmd, access)
  BSU.RemovePlayerPrivilege(steamid, BSU.PRIV_CMD, string.lower(cmd))
end

-- returns bool if the player has access to the command
function BSU.PlayerHasCommandAccess(ply, name)
  if not ply:IsValid() then return true end -- a NULL entity means it was ran through the server console so we don't need to check

  name = string.lower(name)
  local cmd = cmds[name]
  if not cmd then error("Command '" .. name .. "' does not exist") end

  local accessPriv = BSU.CheckPlayerPrivilege(ply:SteamID64(), BSU.PRIV_CMD, name)
  if accessPriv ~= nil then return accessPriv end
  if cmd.access == BSU.CMD_NOONE then return false end
  if cmd.access == BSU.CMD_ANYONE then return true end
  local usergroup = ply:GetUserGroup()
  return usergroup == "superadmin" and true or (cmd.access == BSU.CMD_ADMIN_ONLY and usergroup == "admin" and true or false)
end

-- make a player run a command (allows players who don't have access to the command to still run it)
function BSU.UnsafeRunCommand(name, ply, argStr)
  local cmd = cmds[name]
  if not cmd then error("Command '" .. name .. "' does not exist") end

  _tempUser = ply or NULL
  _tempArgs = argStr and parseArgs(argStr, true) or ""
  xpcall(cmd.func, function(err) BSU.SendChatMsg(ply, Color(255, 127, 0), "Command errored with: " .. string.Split(err, ": ")[2]) end, cmd, ply, #_tempArgs, argStr)
end

-- make a player run a command (does nothing if they do not have access to the command)
function BSU.RunCommand(name, ply, argStr)
  if not BSU.PlayerHasCommandAccess(ply, name) then
    return BSU.SendChatMsg(ply, Color(255, 127, 0), "You don't have permission to use this command")
  end
  BSU.UnsafeRunCommand(name, ply, argStr)
end

concommand.Add("bsu", function(ply, _, args, argStr)
  if not args[1] then return end
  local name = string.lower(args[1])
  local cmd = cmds[name]
  if not cmd then return BSU.SendConMsg(ply, color_white, "Unknown BSU command: " .. name) end

  -- execute the command
  BSU.RunCommand(name, ply, string.sub(argStr, #name + 2))
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE)