--[[
	CPPI for external addons to interface with the prop protection
	
	https://ulyssesmod.net/archive/CPPI_v1-3.pdf
]]

local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

CPPI = {}
CPPI_NOTIMPLEMENTED = 0
CPPI_DEFERRED = 1

function CPPI:GetName()
	return "BSU"
end

function CPPI:GetVersion()
	return "1.0"
end

function CPPI:GetInterfaceVersion()
	return 1.3
end

function entMeta:CPPIGetOwner()
	local owner = BSU.GetOwner(self)
	if owner and owner:IsPlayer() then
		return owner, CPPI_NOTIMPLEMENTED
	end
end

if SERVER then
	function plyMeta:CPPIGetFriends()
		local friends = {}
		for _, v in ipairs(BSU.GetPlayerPermissionList(self, BSU.PP_TOOLGUN)) do
			if #friends < 64 then -- return value must have less than or equal to 64 players
				table.insert(friends, v)
			end
		end
		return friends
	end

	function entMeta:CPPISetOwner(ply)
		if ply == nil then
			BSU.SetOwnerless(self)
		elseif isentity(ply) and ply:IsPlayer() then
			BSU.SetOwner(self, ply)
		else
			return false
		end
		return true
	end

	function entMeta:CPPISetOwnerUID()
		return CPPI_NOTIMPLEMENTED
	end

	function entMeta:CPPICanTool(ply)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_TOOLGUN) ~= false
	end

	function entMeta:CPPICanPhysgun(ply)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_PHYSGUN) ~= false
	end

	function entMeta:CPPICanPickup(ply)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_GRAVGUN) ~= false
	end

	entMeta.CPPICanPunt = entMeta.CPPICanPickup

	function entMeta:CPPICanUse(ply)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_USE) ~= false
	end

	function entMeta:CPPICanDamage(ply)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_DAMAGE) ~= false
	end

	entMeta.CPPICanDrive = entMeta.CPPICanUse

	entMeta.CPPICanProperty = entMeta.CPPICanTool

	entMeta.CPPICanEditVariable = entMeta.CPPICanTool
else
	function plyMeta:CPPIGetFriends()
		if self ~= LocalPlayer() then return CPPI_NOTIMPLEMENTED end
		local friends = {}
		for _, v in ipairs(BSU.GetPlayerPermissionList(BSU.PP_TOOLGUN)) do
			if #plys < 64 then -- return value must have less than or equal to 64 players
				table.insert(friends, v)
			end
		end
		return friends
	end
end
