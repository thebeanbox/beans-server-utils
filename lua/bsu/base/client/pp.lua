--- base/client/pp.lua

concommand.Add("bsu_reset_permissions", function()
	BSU.SQLQuery("DROP TABLE IF EXISTS %s", BSU.EscOrNULL(BSU.SQL_PP, true))
	BSU.SQLCreateTable(BSU.SQL_PP, string.format(
		[[
			steamid TEXT PRIMARY KEY,
			permission INTEGER NOT NULL
		]]
	))
end)

local function addPropProtectionMenu()
	spawnmenu.AddToolMenuOption("Utilities", "BSU", "Prop Protection", "Prop Protection", "", "", function(pnl)
		pnl:ClearControls()

		pnl:Button("Reset Permissions", "bsu_reset_permissions")

		local list = vgui.Create("DIconLayout")
		pnl:AddItem(list)
		list:SetHeight(2000)
		list:SetSpaceY(4)

		local top = list:Add("DIconLayout")
		top:SetSize(225, 16)
		top:SetSpaceX(9)
		local label = top:Add("DLabel")
		label:SetSize(100, 16)
		label:SetText("[ Players ]")
		label:SetColor(color_black)
		local icons = { "wrench", "wrench_orange", "wand", "ruby", "gun" }
		for i = 1, 5 do
			local icon = top:Add("DImage")
			icon:SetSize(16, 16)
			icon:SetImage(string.format("icon16/%s.png", icons[i]))
		end

		local elems = {}

		local function boxOnChange(self, checked)
			if self.ply:IsValid() then
				if checked then
					BSU.GrantPermission(self.ply, self.perm)
				else
					BSU.RevokePermission(self.ply, self.perm)
				end
			end
		end

		local function update()
			local oldElems = elems
			elems = {}
			for _, v in ipairs(player.GetHumans()) do
				if v == LocalPlayer() then continue end
				local oldElem = oldElems[v]
				if oldElem then
					oldElem.name:SetText(v:Nick()) -- incase name changed
					elems[v] = oldElem
					oldElems[v] = nil
				else -- add player element
					local elem = list:Add("DIconLayout")
					elems[v] = elem
					elem.OwnLine = true
					elem:SetSize(225, 15)
					elem:SetSpaceX(10)

					local name = elem:Add("DLabel")
					elem.name = name
					name:SetSize(100, 15)
					name:SetText(v:Nick())
					name:SetColor(color_black)

					for i = 1, 5 do
						local box = elem:Add("DCheckBox")
						elem.box = box
						box.ply = v
						box.perm = math.pow(2, i - 1)
						box:SetValue(BSU.CheckPermission(v:SteamID64(), box.perm))
						box.OnChange = boxOnChange
					end
				end
			end

			-- remove disconnected players elements
			for _, v in pairs(oldElems) do
				v:Remove()
			end
		end
		timer.Create("BSU_UpdatePropProtectionMenu", 1, 0, update)

		pnl:CheckBox("Persist permissions across sessions", "bsu_permission_persist")
		pnl:CheckBox("Allow props to take fire damage", "bsu_allow_fire_damage")
	end)
end

hook.Add("PopulateToolMenu", "BSU_AddPropProtectionMenu", addPropProtectionMenu)

local color_bg = Color(0, 0, 0, 75)
local hudX, hudY = 37, ScrH() - 180

local font = "BSU_PP_HUD"
surface.CreateFont(font, {
	font = "Verdana",
	size = 16,
	weight = 400,
	antialias = true,
	shadow = true
})

local function drawPropProtectionHUD()
	local ply = LocalPlayer()

	if not GetConVar("bsu_show_propinfo"):GetBool() then return end

	local trace = util.TraceLine(util.GetPlayerTrace(ply))
	if trace.HitNonWorld then
		local ent = trace.Entity
		if ent:IsValid() and not ent:IsPlayer() then
			local name, steamid = BSU.GetOwnerName(ent) or "N/A", BSU.GetOwnerSteamID(ent)
			local text = "Owner: " .. name .. (steamid and "<" .. steamid .. ">" or "") .. "\n" .. ent:GetModel() .. "\n" .. tostring(ent)
			surface.SetFont(font)
			local w, h = surface.GetTextSize(text)
			draw.RoundedBox(4, hudX, hudY, w + 8, h + 8, color_bg)
			draw.DrawText(text, font, hudX + 4, hudY + 4, color_white, TEXT_ALIGN_LEFT)
		end
	end
end

hook.Add("HUDPaint", "BSU_DrawPropProtectionHUD", drawPropProtectionHUD)

if not GetConVar("bsu_permission_persist"):GetBool() then
	RunConsoleCommand("bsu_reset_permissions")
end

hook.Add("InitPostEntity", "BSU_SendPermissions", BSU.SendPermissions)
