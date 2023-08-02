-- base/server/pdata.lua

local function networkPData(data)
	local ply = Player(data.userid)
	for k, v in pairs(BSU.GetAllPData(ply), true) do -- get only networked data
		ply:SetNW2String("bsu_" .. k, v)
	end
end

gameevent.Listen("player_activate")
hook.Add("player_activate", "BSU_NetworkPData", networkPData)
