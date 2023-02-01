-- lib/client/util.lua

function BSU.LoadModules(dir)
	dir = dir or BSU.DIR_MODULES

	local clDir = dir .. "client/"

	local shFiles, folders = file.Find(dir .. "*", "LUA")
	local clFiles = file.Find(clDir .. "*", "LUA")

	-- run shared modules
	for _, v in ipairs(shFiles) do
		if not string.EndsWith(v, ".lua") then continue end
		include(dir .. v)
	end

	-- run client-side modules
	for _, v in ipairs(clFiles) do
		if not string.EndsWith(v, ".lua") then continue end
		include(clDir .. v)
	end

	for _, v in ipairs(folders) do
		v = string.lower(v)
		if v == "client" then continue end
		BSU.LoadModules(dir .. v .. "/")
	end
end

-- prints a message to console (intended to be called by client RPC)
function BSU.SendConMsg(...)
	MsgC(...)
	MsgN()
end