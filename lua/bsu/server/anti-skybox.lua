-- initally created by wisp22 (hori)
-- this script's purpose is to keep guests from spawning props in the skybox, just because its really fucking annoying and chances are a minge wont last long enough to get frequent anyway, and building extra stuff in the skybox isnt that important to people anyway.
/*
if SERVER then
	print("BSU Skybox Protection - initalizing!")
    local map = game.GetMap()
    sql.Query("CREATE TABLE IF NOT EXISTS bsu_skybox_vectors(mapName TEXT PRIMARY KEY, x1 REAL, x2 REAL, y1 REAL, y2 REAL, z1 REAL, z2 REAL)")
    sql.Query(string.format("INSERT INTO bsu_skybox_vectors(mapName, corner1, corner2) VALUES('%s', '%f', '%f', '%f', '%f', '%f', '%f')", "gm_flatgrass", -7735, -7796, -16128, 8535, 8476, -13317))

    local mapData = sql.QueryRow(string.format("SELECT * FROM bsu_skybox_vectors WHERE mapName = '%s'"), map)

    PrintTable(mapData)
end
