-- lib/server/util.lua

function BSU.LoadModules(dir)
	dir = dir or BSU.DIR_MODULES

	local svDir = dir .. "server/"
	local clDir = dir .. "client/"

	local shFiles, folders = file.Find(dir .. "*", "LUA")
	local svFiles = file.Find(svDir .. "*", "LUA")
	local clFiles = file.Find(clDir .. "*", "LUA")

	-- run server-side modules
	for _, v in ipairs(svFiles) do
		if not string.EndsWith(v, ".lua") then continue end
		include(svDir .. v)
	end

	-- run/include shared modules
	for _, v in ipairs(shFiles) do
		if not string.EndsWith(v, ".lua") then continue end
		include(dir .. v)
		AddCSLuaFile(dir .. v)
	end

	-- include client-side modules
	for _, v in ipairs(clFiles) do
		if not string.EndsWith(v, ".lua") then continue end
		AddCSLuaFile(clDir .. v)
	end

	for _, v in ipairs(folders) do
		v = string.lower(v)
		if v == "server" or v == "client" then continue end
		BSU.LoadModules(dir .. v .. "/")
	end
end

-- send a chat message to players (expects a player or NULL entity, or a table that can include both)
function BSU.SendChatMsg(plys, ...)
	if not plys then
		plys = player.GetHumans()
		table.insert(plys, NULL) -- NULL entity = server console
	elseif not istable(plys) then
		plys = { plys }
	end

	for _, v in ipairs(plys) do
		if v:IsValid() then
			BSU.ClientRPC(v, "chat.AddText", ...)
		else
			MsgC(BSU.FixMsgCArgs(...))
			MsgN()
		end
	end
end

-- send a console message to players (expects a player or NULL entity, or a table that can include both)
function BSU.SendConsoleMsg(plys, ...)
	if not plys then
		plys = player.GetHumans()
		table.insert(plys, NULL) -- NULL entity = server console
	elseif not istable(plys) then
		plys = { plys }
	end

	for _, v in ipairs(plys) do
		if v:IsValid() then
			BSU.ClientRPC(plys, "BSU.SendConsoleMsg", ...)
		else
			MsgC(BSU.FixMsgCArgs(...))
			MsgN()
		end
	end
end
