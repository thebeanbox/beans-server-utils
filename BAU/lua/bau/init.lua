file.CreateDir("bau") -- adds directory in garrysmod/data (to be used later)

include("bau/shared/commands.lua")
AddCSLuaFile("bau/shared/commands.lua")

AddCSLuaFile("autorun/bau_init.lua") -- init for client side
