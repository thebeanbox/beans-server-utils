-- initally created by wisp22 (hori)
-- this script's purpose is to keep guests from spawning props in the skybox, just because its really fucking annoying and chances are a minge wont last long enough to get frequent anyway, and building extra stuff in the skybox isnt that important to people anyway.

if SERVER then
	print("BSU Skybox Protection - initalizing!")
    dataFile = "bsu/anti-skybox_data.json"

    if not file.Exists("bsu/", "DATA") then
        file.CreateDir("bsu/")
        print("BSU Skybox Protection - data/bsu did not exist! creating directory, the fact that it did not exist is probably very bad!")
    end

    if not file.Exists(dataFile, "DATA") then
        local baseFileWrite = {
            gm_flatgrass = { Vector(-7735,-7796,-16128), Vector(8535,8476,-13317) },
            gm_bigcity_night = { Vector(3060, 3060, 4200), Vector(-3060, -3060, 5800) }
        }
        file.Write(dataFile, util.TableToJSON(baseFileWrite))
        print("BSU Skybox Protection - data/" .. dataFile .. " did not exist (this is bad!) creating file, make sure to add skybox data for the current map!")
    end
    skyboxDataTable = any
	pos = any

    function reloadSkyboxFile()
        print("BSU Skybox Protection - reloading skybox dataset!")
        skyboxDataTable = file.Read(dataFile, "DATA")
        PrintTable(util.JSONToTable(skyboxDataTable))
        pos = util.JSONToTable(skyboxDataTable)
	util.AddNetworkString("BSU_SkyboxNetMessage") -- get the networking for the hud ready to go
	if !pos[game.GetMap()] then print("BSU Skybox Protection - this map does not have vectors set for the skybox! this will not operate until vectors are set.") end

    end
    timer.Simple(3, reloadSkyboxFile)

	hook.Add("Think", "BSU_SkyboxCheck", function()
		if pos[game.GetMap()] then
			local c1 = pos[game.GetMap()][1]
			local c2 = pos[game.GetMap()][2]
			local fents = ents.FindInBox(c1, c2)

			for i, v in ipairs( player.GetAll() ) do
				net.Start("BSU_SkyboxNetMessage")
				net.WriteBool(v:GetPos():WithinAABox(c1, c2))
				net.Send(v)
			end

			for i=1, #fents do
				local current = fents[i]
				if !current:IsPlayer() and !current:GetClass()=="predicted_viewmodel" then
					print("a!")
					current:Remove()
					current:GetOwner():PrintMessage(HUD_PRINTTALK, "you aren't permitted to build here yet!")
				end
			end
		end
	end)
end
