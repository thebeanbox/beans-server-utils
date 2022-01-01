-- base/server/players.lua
-- handles player data stuff

--[[
  Player NW2Var Info

  BSU_Init        - (bool)   the player has been initialized
  BSU_TotalTime   - (int)    (see Player SQL totaltime)
  BSU_ConnectTime - (int)    (in seconds) utc unix timestamp when the player joined the server
  BSU_OS          - (string) current OS the client is using (Windows, Linux or macOS)
  BSU_Country     - (string) 2-letter country code of the client
  BSU_TimeOffset  - (int)    utc time offset (-12 to 14)
]]

-- initialize player data
local function initializePlayer(ply)
  local id64 = ply:SteamID64()
  local plyData = BSU.GetPlayerData(ply)
  
  if not plyData then -- this is the first time this player has joined
    BSU.RegisterPlayer(id64, BSU.DEFAULT_GROUP)
  end
end

hook.Add("PlayerAuthed", "BSU_InitializePlayer", initializePlayer)

-- initialize player values
local function initializePlayerValues(ply)
  if ply:GetNW2Bool("BSU_Init") then return end
  ply:SetNW2Bool("BSU_Init", true)

  if not ply:IsBot() then
    local plyData = BSU.GetPlayerData(ply)
    local groupData = BSU.GetGroupByID(plyData.groupid)

    -- set group values
    ply:SetTeam(plyData.groupid)
    ply:SetUserGroup(groupData.usergroup or "user")

    -- some other values
    ply:SetNW2Int("BSU_TotalTime", plyData.totaltime)

    -- request for client system info
    BSU.RequestClientInfo(ply)
  else
    local groupData = BSU.GetGroupByID(BSU.BOT_GROUP)

    -- set group values
    ply:SetTeam(BSU.BOT_GROUP)
    ply:SetUserGroup(groupData.usergroup or "user")

    -- some other values
    ply:SetNW2Int("BSU_TotalTime", 0)
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

-- receive some client data and register networked values (see BSU.RequestClientInfo)
net.Receive("BSU_ClientInfo", function(_, ply)
  local os = net.ReadString()
  local country = net.ReadString()
  local timeOffset = net.ReadInt(5)

  ply:SetNW2String("BSU_OS", os)
  ply:SetNW2String("BSU_Country", country)
  ply:SetNW2Int("BSU_TimeOffset", timeOffset)
end)

-- fix glitchy movement when grabbing players
hook.Add("OnPhysgunPickup", "BSU_PlayerPhysgunPickup", function(ply, ent)
  if ent:IsPlayer() then ent:SetMoveType(MOVETYPE_NONE) end
end)

hook.Add("PhysgunDrop", "BSU_PlayerPhysgunDrop", function(ply, ent)
  if ent:IsPlayer() then ent:SetMoveType(MOVETYPE_WALK) end
end)