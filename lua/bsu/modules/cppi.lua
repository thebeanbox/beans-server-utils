--[[
	CPPI for external addons to interface with the prop protection
	
	https://ulyssesmod.net/archive/CPPI_v1-3.pdf
]]

local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

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

function ENTITY:CPPIGetOwner()
	local owner = BSU.GetOwner(self)
	if owner then
		if owner:IsValid() then
			return owner, CPPI_NOTIMPLEMENTED
		else
			return nil, CPPI_NOTIMPLEMENTED
		end
	end
end

if SERVER then
	function PLAYER:CPPIGetFriends()
		return BSU.GetPlayerFriends(self)
	end

	function ENTITY:CPPISetOwner(ply)
		if ply == nil then
			BSU.SetOwnerless(self)
		elseif isentity(ply) and ply:IsValid() and ply:IsPlayer() then
			BSU.SetOwner(self, ply)
		else
			return false
		end
		return true
	end

	function ENTITY:CPPISetOwnerUID()
		return CPPI_NOTIMPLEMENTED
	end

	function ENTITY:CPPICanTool(ply, ...)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_TOOLGUN, ...) ~= false
	end

	function ENTITY:CPPICanPhysgun(ply)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_PHYSGUN) ~= false
	end

	function ENTITY:CPPICanPickup(ply)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_GRAVGUN) ~= false
	end

	ENTITY.CPPICanPunt = ENTITY.CPPICanPickup

	function ENTITY:CPPICanUse(ply)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_USE) ~= false
	end

	function ENTITY:CPPICanDamage(ply)
		return BSU.PlayerHasPermission(ply, self, BSU.PP_DAMAGE) ~= false
	end

	ENTITY.CPPIDrive = ENTITY.CPPICanTool

	ENTITY.CPPICanProperty = ENTITY.CPPICanTool

	ENTITY.CPPICanEditVariable = ENTITY.CPPICanTool
else
	function PLAYER:CPPIGetFriends()
		if self ~= LocalPlayer() then return CPPI_NOTIMPLEMENTED end
		return BSU.GetPlayerFriends()
	end
end
