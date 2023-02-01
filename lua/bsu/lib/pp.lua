-- lib/pp.lua (SHARED)

-- returns owner of the entity or nil if it never had an owner (either a player or the world entity)
function BSU.GetEntityOwner(ent)
	local owner = ent:GetNW2Entity("BSU_Owner", false)
	if owner then return owner end
end

-- returns name of the owner of the entity or nil if it never had an owner ('World' if the owner is the world entity)
function BSU.GetEntityOwnerName(ent)
	local name = ent:GetNW2String("BSU_OwnerName", false)
	if name then return name end
end

-- returns steam id of the owner of the entity or nil if it never had an owner (nil if owned by the world entity)
function BSU.GetEntityOwnerID(ent)
	local id = ent:GetNW2String("BSU_OwnerID", false)
	if id then return id end
end