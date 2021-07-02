if SERVER then
	print("BSU Skybox Protection - initalizing!")

	pos = {--Corner1, Corner2
		gm_flatgrass = { Vector(-7735,-7796,-16128), Vector(8535,8476,-13017) }
	} -- in the future this would probably be integrated into a gui of sorts, updated dynamically so if an admin sees that the map doesnt have the corners set, we can add them on the fly.

    if not pos[game.GetMap()] then print("BSU Skybox Protection - this map does not have vectors set for the skybox! this will not operate until vectors are set.") end

	function skyboxCheck(ply, ent)
		if not pos[game.GetMap()] then return end
		local c1 = pos[game.GetMap()][1]
		local c2 = pos[game.GetMap()][2]

		isInSkybox = ent:GetPos():WithinAABox( c1, c2 )
			if isInSkybox --[[ !& add the check for if the player is base guest rank ]] then
				-- this would run if the player was the base rank and wasnt allowed to spawn props in the skybox yet
				ent:Remove()
				ply:PrintMessage(HUD_PRINTTALK, "you aren't permitted to build here yet!")
			end
	end

	hook.Add("PlayerSpawnedProp", "BSU_SkyboxCheckPropSpawned", function(ply, mdl, ent)
		skyboxCheck(ply, ent)
	end)
	hook.Add("PlayerSpawnedEffect", "BSU_SkyboxCheckEffectSpawned", function(ply, mdl, ent)
		skyboxCheck(ply, ent)
	end)
	hook.Add("PlayerSpawnedNPC", "BSU_SkyboxCheckNPCSpawned", function(ply, ent)
		skyboxCheck(ply, ent)
	end)
	hook.Add("PlayerSpawnedRagdoll", "BSU_SkyboxCheckRagdollSpawned", function(ply, mdl, ent)
		skyboxCheck(ply, ent)
	end)
	hook.Add("PlayerSpawnedSENT", "BSU_SkyboxCheckSENTSpawned", function(ply, ent)
		skyboxCheck(ply, ent)
	end)
	hook.Add("PlayerSpawnedSWEP", "BSU_SkyboxCheckSWEPSpawned", function(ply, ent)
		skyboxCheck(ply, ent)
	end)
	hook.Add("PlayerSpawnedVehicle", "BSU_SkyboxCheckVehicleSpawned", function(ply, ent)
		skyboxCheck(ply, ent)
	end)

end
