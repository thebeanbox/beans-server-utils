-- lib/pp.lua (SHARED)

BSU._owners = BSU._owners or {} -- owner data
BSU._entowners = BSU._entowners or {} -- entity index -> owner id lookup
BSU._ownerents = BSU._ownerents or {} -- owner id -> entity index lookup lookup

local infoUpdates, entsUpdates = {}, {}

local function sendOwnerUpdates()
	if next(infoUpdates) ~= nil then
		for id, info in pairs(infoUpdates) do
			for k, v in pairs(info) do
				net.Start("bsu_owners")
					net.WriteUInt(1, 3) -- update owner info
					net.WriteInt(id, 16)
					net.WriteString(k)
					net.WriteType(v)
				net.Broadcast()
			end
		end

		infoUpdates = {}
	end

	if next(entsUpdates) ~= nil then
		local owners, ownerless = {}, {}

		for entindex, id in pairs(entsUpdates) do
			if id then
				if not owners[id] then owners[id] = {} end
				table.insert(owners[id], entindex)
			else
				table.insert(ownerless, entindex)
			end
		end

		if next(owners) ~= nil then
			for id, ents in pairs(owners) do
				for _, entindex in ipairs(ents) do
					net.Start("bsu_owners")
						net.WriteUInt(2, 3) -- set entity owner
						net.WriteInt(id, 16)
						net.WriteUInt(entindex, 13)
					net.Broadcast()
				end
			end
		end

		if next(ownerless) ~= nil then
			for _, entindex in ipairs(ownerless) do
				net.Start("bsu_owners")
					net.WriteUInt(3, 3) -- clear entity owner
					net.WriteUInt(entindex, 13)
				net.Broadcast()
			end
		end

		entsUpdates = {}
	end
end

local function updateOwnerInfo(id, key, value)
	if not isstring(key) or value == nil then return end

	key = string.lower(key)

	if BSU._owners[id] then
		if BSU._owners[id][key] == value then return end -- value didn't change
	else
		BSU._owners[id] = {}
	end
	BSU._owners[id][key] = value

	if SERVER then
		if not infoUpdates[id] then infoUpdates[id] = {} end
		infoUpdates[id][key] = value
		timer.Create("BSU_SendOwnerUpdates", 0, 1, sendOwnerUpdates) -- send updates next tick
	end
end

local function clearEntityOwner(entindex)
	local id = BSU._entowners[entindex]
	if not id then return end -- already ownerless

	BSU._entowners[entindex] = nil
	BSU._ownerents[id] = BSU._ownerents[id] or {}
	BSU._ownerents[id][entindex] = nil
	if id > 0 and not Player(id):IsValid() and next(BSU._ownerents[id]) == nil then
		BSU._owners[id] = nil -- delete owner data (owner is disconnected player with no props)
	end

	if SERVER then
		entsUpdates[entindex] = false
		timer.Create("BSU_SendOwnerUpdates", 0, 1, sendOwnerUpdates) -- send updates next tick
	end
end

local function setEntityOwner(entindex, id)
	if BSU._entowners[entindex] == id then return end -- already owned by this owner id

	BSU._entowners[entindex] = id
	BSU._ownerents[id] = BSU._ownerents[id] or {}
	BSU._ownerents[id][entindex] = true

	if SERVER then
		entsUpdates[entindex] = id
		timer.Create("BSU_SendOwnerUpdates", 0, 1, sendOwnerUpdates) -- send updates next tick
	end
end

local function transferOwnerData(id, id2)
	local info = BSU._owners[id]
	if not info then return end -- owner doesn't exist (happens clientside when server transfers owner data and we haven't received any owner data yet)
	local ents = BSU._ownerents[id]

	BSU._owners[id2] = BSU._owners[id2] or {}
	BSU._ownerents[id2] = BSU._ownerents[id2] or {}

	for k, v in pairs(info) do
		BSU._owners[id2][k] = v
	end

	for entindex, _ in pairs(ents) do
		BSU._ownerents[id2][entindex] = true
		BSU._entowners[entindex] = id2
	end

	BSU._owners[id] = nil
	BSU._ownerents[id] = nil

	if SERVER then
		net.Start("bsu_owners")
			net.WriteUInt(4, 3) -- transfer owner data
			net.WriteInt(id, 16)
			net.WriteInt(id2, 16)
		net.Broadcast()
	end
end

function BSU.SetOwnerInfo(owner, key, value)
	if not IsValid(owner) or (not owner:IsPlayer() and not owner:IsWorld()) then return end
	local id = owner:IsPlayer() and owner:UserID() or -1
	updateOwnerInfo(id, key, value)
end

function BSU.SetOwnerless(ent)
	if not IsValid(ent) or ent:IsPlayer() then return end
	clearEntityOwner(ent:EntIndex())
	ent:RemoveCallOnRemove("BSU_SetOwnerless")
end

function BSU.SetOwner(ent, owner)
	if not IsValid(ent) or ent:IsPlayer() then return end
	if not IsValid(owner) or (not owner:IsPlayer() and not owner:IsWorld()) then return end
	local id = owner:UserID()
	updateOwnerInfo(id, "name", owner:Nick()) -- used for HUD display
	updateOwnerInfo(id, "steamid", owner:SteamID()) -- used for regaining player ownership after rejoining
	setEntityOwner(ent:EntIndex(), id)
	ent:CallOnRemove("BSU_SetOwnerless", BSU.SetOwnerless)
end

function BSU.SetOwnerWorld(ent)
	if not IsValid(ent) or ent:IsPlayer() then return end
	updateOwnerInfo(-1, "name", "World") -- used for HUD display
	setEntityOwner(ent:EntIndex(), -1)
end

function BSU.ReplaceOwner(from, to)
	if not IsValid(from) or from:IsPlayer() then return end
	if not IsValid(to) or to:IsPlayer() then return end

	local id = BSU._entowners[from:EntIndex()]
	if not id then return end -- is ownerless

	BSU.SetOwnerless(from)
	BSU.SetOwner(to, id)
end

function BSU.TransferOwnerData(id, owner)
	if not IsValid(owner) or (not owner:IsPlayer() and not owner:IsWorld()) then return end
	local id2 = owner:IsPlayer() and owner:UserID() or -1
	transferOwnerData(id, id2)
end

if SERVER then
	function BSU.SendOwnerData(ply)
		net.Start("bsu_owners")
			net.WriteUInt(0, 3) -- init
			net.WriteUInt(table.Count(BSU._owners), 7)
		for id, info in pairs(BSU._owners) do
			net.WriteInt(id, 16)

			net.WriteUInt(math.min(table.Count(info), 2 ^ 12 - 1), 12)
			for k, v in pairs(info) do
				net.WriteString(k)
				net.WriteType(v)
			end

			local ents = BSU._ownerents[id]
			net.WriteUInt(math.min(table.Count(ents), 2 ^ 13 - 1), 13)
			for entindex, _ in pairs(ents) do
				net.WriteUInt(entindex, 13)
			end
		end
		net.Send(ply)
	end
end

-- returns owner id by steamid (prioritizes lower owner ids, nil if no owner with this steamid)
function BSU.GetOwnerIDBySteamID(steamid)
	local ids = table.GetKeys(BSU._owners)
	table.sort(ids, function(a, b) return a < b end)
	for _, id in ipairs(ids) do
		if BSU._owners[id].steamid == steamid then
			return id
		end
	end
end

-- returns owner of the entity (can be a player or the world, nil if entity is ownerless, NULL entity if player is disconnected)
function BSU.GetOwner(ent)
	if not IsValid(ent) then return end
	local id = BSU._entowners[ent:EntIndex()]
	if not id then return end
	if id == -1 then return game.GetWorld() end
	return Player(id)
end

-- returns info about the entity owner (nil if entity is ownerless or there's no info with the key)
function BSU.GetOwnerInfo(ent, key)
	if not IsValid(ent) then return end
	local id = BSU._entowners[ent:EntIndex()]
	if not id or not BSU._owners[id] then return end
	return BSU._owners[id][string.lower(key)]
end

-- returns name of the entity owner (nil if entity is ownerless)
function BSU.GetOwnerName(ent)
	return BSU.GetOwnerInfo(ent, "name")
end

-- returns steam id of the entity owner (nil if entity is ownerless or is owned by the world entity)
function BSU.GetOwnerSteamID(ent)
	return BSU.GetOwnerInfo(ent, "steamid")
end

if CLIENT then
	net.Receive("bsu_owners", function()
		local kind = net.ReadUInt(3)
		if kind == 0 then -- init owner data
			local owners = net.ReadUInt(7)
			for _ = 1, owners do
				local id = net.ReadInt(16)

				local info = net.ReadUInt(12)
				for _ = 1, info do
					local key, value = net.ReadString(), net.ReadType()
					updateOwnerInfo(id, key, value)
				end

				local ents = net.ReadUInt(13)
				for _ = 1, ents do
					local entindex = net.ReadUInt(13)
					setEntityOwner(entindex, id)
				end
			end
		elseif kind == 1 then -- update owner info
			local id, key, value = net.ReadInt(16), net.ReadString(), net.ReadType()
			updateOwnerInfo(id, key, value)
		elseif kind == 2 then -- set entity owner
			local id, entindex = net.ReadInt(16), net.ReadUInt(13)
			setEntityOwner(entindex, id)
		elseif kind == 3 then -- clear entity owner
			local entindex = net.ReadUInt(13)
			clearEntityOwner(entindex)
		elseif kind == 4 then -- transfer owner data
			local id1, id2 = net.ReadInt(16), net.ReadInt(16)
			transferOwnerData(id1, id2)
		end
	end)
end
