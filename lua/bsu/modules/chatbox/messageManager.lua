-- chatbox/messageManager.lua by Bonyoze
-- Manager formatting messages and player avatars

bsuChat.imageDataCache = {}

function bsuChat.formatMsg(...) -- formats regular print message data table for use in html
	local msg = {}
	
	for k, arg in pairs({...}) do
		if type(arg) == "string" then
			table.Add(msg, bsuChat.formatPlyMsg(arg))
		elseif type(arg) == "table" then
			table.insert(msg,
				{
					type = "color",
					value = arg
				}
			)
		elseif type(arg) == "Player" and arg:IsPlayer() then
			table.Add(msg,
				{
					{
						type = "color",
						value = team.GetColor(arg:Team())
					},
					{
						type = "text",
						value = arg:Nick()
					}
				}
			)
		elseif type(arg) == "Entity" then
			table.insert(msg,
				{
					type = "text",
					value = tostring(arg)
				}
			)
		end
	end
	
	return msg
end

function bsuChat.formatPlyMsg(text, oldData, oldPos) -- formats player-sent message for use in html
	local data = oldData or {}
	local pos = oldPos or 0
	local index1, index2

	while true do
		index1 = string.find(text, "[", pos, true)
		if index1 then
			index2 = string.find(text, "]", pos, true)
			if index2 then
				local sub = string.sub(text, index1 + 1, index2 - 1)

				if not (pos == 0 and index1 - 1 == 0) and #string.sub(text, pos, index1 - 1) > 0 then
					table.insert(data,
						{
							type = "text",
							value = string.sub(text, pos, index1 - 1)
						}
					)
				end
				
				local type, value

				local splitPos = string.find(sub, ":", 0, true)
				if splitPos then
					type = string.lower(string.Trim(string.sub(sub, 0, splitPos - 1)))
					value = string.Trim(string.Replace(string.Replace(string.sub(sub, splitPos + 1), "\"", ""), "'", ""))
				else
					type = string.lower(string.Trim(sub))
				end

				local bool, newValue

				if type[1] ~= "/" then
					bool = true
				else
					bool = false
					type = string.sub(type, 2)
				end

				local newValue

				if type == "url" or type == "link" or type == "hyperlink" then
					if value then
						local args = string.Split(value, ",")
						local url, text = string.Trim(args[1]), (args[2] and #string.Trim(args[2]) > 0) and string.Trim(args[2]) or nil

						local domain = (string.sub(string.lower(url), 0, 7) == "http://" and string.sub(url, 8)) or (string.sub(string.lower(url), 0, 8) == "https://" and string.sub(url, 9)) or nil
						if domain and #string.Split(domain, ".") >= 2 then
							newValue = {url = url, text = text} -- url and link name
							type = "hyperlink"
						end
					end
				elseif type == "img" or type == "image" then
					if value then

						local domain = (string.sub(string.lower(value), 0, 7) == "http://" and string.sub(value, 8)) or (string.sub(string.lower(value), 0, 8) == "https://" and string.sub(value, 9)) or nil
						if domain and #string.Split(domain, ".") >= 2 then
							newValue = value
							type = "image"
						end
					end
				elseif type == "hex" then
					if value then
						local hex = value:gsub("#", "");
						pcall(function()
							newValue = Color(tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))) -- some color
							type = "color"
						end)
					else
						newValue = color_white -- default color
						type = "color"
					end
				elseif type == "rgb" then
					if value then
						local r, g, b = string.match(value, "([^,]+),([^,]+),([^,]+)")
						pcall(function()
							newValue = Color(r, g, b) -- some color
							type = "color"
						end)
					else
						newValue = color_white -- default color
						type = "color"
					end
				elseif type == "i" or type == "italic" or type == "italics" then
					newValue = bool -- italics or no italics
					type = "italic"
				elseif type == "b" or type == "bold" then
					newValue = bool -- bold or no bold
					type = "bold"
				elseif type == "strike" or type == "strikethrough" then
					newValue = bool -- strikethrough or no strikethrough
					type = "strikethrough"
				end
				
				if newValue ~= nil then
					table.insert(data,
						{
							type = type,
							value = newValue
						}
					)
				else
					table.insert(data,
						{
							type = "text",
							value = "[" .. sub .. "]"
						}
					)
				end

				pos = index2 + 1
				continue
			end
		end

		if pos <= #text then
			table.insert(data,
				{
					type = "text",
					value = string.sub(text, pos)
				 }
			)
		end

		break
	end
	
	for _, obj in ipairs(data) do
		if obj.type == "text" or obj.type == "hyperlink" or obj.type == "image" then
			return data
		end
	end

	return {
		{
			type = "text",
			value = text
		}
	}
end

function bsuChat.loadPlyAvatarIcon(ply, data) -- gets player's avatar in base64
	data.avatar = "data:image/jpeg;base64," .. util.Base64Encode(BSU:GetPlayerAvatarData(ply), false)
	bsuChat.send(data)
end