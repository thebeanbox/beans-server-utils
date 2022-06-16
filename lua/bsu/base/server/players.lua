-- base/server/players.lua
-- handles player data stuff

--[[
  Player NW2Var Info

  BSU_Init        - (bool)   the player has been initialized
  BSU_TotalTime   - (int)    (in seconds) how long the player has been on the server (including other sessions)
  BSU_ConnectTime - (int)    (in seconds) utc unix timestamp when the player joined the server
]]

-- initialize player data
local function initializePlayer(ply)
  local id64 = ply:SteamID64()
  local plyData = BSU.GetPlayerData(ply)
  
  if not plyData then -- this is the first time this player has joined
    BSU.RegisterPlayer(id64, BSU.DEFAULT_GROUP)
  end

  -- update some sql player data
  BSU.SetPlayerData(id64, {
    name = ply:Nick(),
    ip = BSU.Address(ply:IPAddress())
  })
end

hook.Add("PlayerAuthed", "BSU_InitializePlayer", initializePlayer)

-- initialize player values
local function initializePlayerValues(ply)
  if ply:GetNW2Bool("BSU_Init") then return end
  ply:SetNW2Bool("BSU_Init", true)

  if ply:IsBot() then
    local groupData = BSU.GetGroupByID(BSU.BOT_GROUP)

    -- set group values
    ply:SetTeam(BSU.BOT_GROUP)
    ply:SetUserGroup(groupData.usergroup or "user")

    ply:SetNW2Int("BSU_TotalTime", 0)
  else
    local plyData = BSU.GetPlayerData(ply)
    local groupData = BSU.GetGroupByID(plyData.groupid)

    -- set group values
    ply:SetTeam(plyData.groupid)
    ply:SetUserGroup(groupData.usergroup or "user")

    ply:SetNW2Int("BSU_TotalTime", plyData.totaltime)

    -- request for client system info
    BSU.RequestClientInfo(ply)
  end

  ply:SetNW2Int("BSU_ConnectTime", BSU.UTCTime())
end

hook.Add("PlayerSpawn", "BSU_InitializePlayerValues", initializePlayerValues)

-- updates the totaltime and lastvisit values of sql player data for all connected players
local function updatePlayerData()
  for k, v in ipairs(player.GetHumans()) do
    local id64 = v:SteamID64()
    BSU.SetPlayerData(id64,
      {
        totaltime = v:GetNW2Int("BSU_TotalTime") + BSU.UTCTime() - v:GetNW2Int("BSU_ConnectTime"),
        lastvisit = BSU.UTCTime()
      }
    )
  end
end

timer.Create("BSU_UpdatePlayerData", 1, 0, updatePlayerData) -- update player data every 60 secs

-- updates the name value of sql player data whenever a player's steam name is changed
gameevent.Listen("player_changename")
hook.Add("player_changename", "BSU_UpdatePlayerDataName", function(data)
  BSU.SetPlayerData(Player(data.userid):SteamID64(), { name = data.newname })
end)

-- receive some client data and update pdata (see BSU.RequestClientInfo)
local function updateClientInfo(_, ply)
  local os = net.ReadUInt(2)
  local country = net.ReadString()
  local timezone = net.ReadFloat()
  
  BSU.SetPData(ply, "os", os == 0 and "Windows" or os == 1 and "Linux" or os == 2 and "macOS" or "N/A", true)
  BSU.SetPData(ply, "country", string.sub(country, 1, 2), true) -- incase if spoofed, remove everything after the first two characters
  BSU.SetPData(ply, "timezone", math.Clamp(timezone, -12, 14), true) -- incase if spoofed, clamp the value
end

net.Receive("bsu_client_info", updateClientInfo)

-- fix glitchy movement when grabbing players
hook.Add("OnPhysgunPickup", "BSU_PlayerPhysgunPickup", function(ply, ent)
  if ent:IsPlayer() then ent:SetMoveType(MOVETYPE_NONE) end
end)

hook.Add("PhysgunDrop", "BSU_PlayerPhysgunDrop", function(ply, ent)
  if ent:IsPlayer() then ent:SetMoveType(MOVETYPE_WALK) end
end)