--- base/client/pp.lua

concommand.Add("bsu_reset_permissions", function()
	-- easiest way is to delete the table and recreate it
	BSU.SQLQuery("DROP TABLE IF EXISTS %s", BSU.SQLEscIdent(BSU.SQL_PP))
	BSU.SQLCreateTable(BSU.SQL_PP, string.format(
		[[
			steamid TEXT PRIMARY KEY,
			permission INTEGER NOT NULL
		]]
	))
	BSU.SendPermissions() -- tell the server we updated our perms for everyone
	hook.Run("BSU_ResetPermissions")
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
		label:SetText("[ Permissions ]")
		label:SetColor(color_black)
		local icons = { "wrench", "wrench_orange", "wand", "ruby", "gun" }
		local tips = { "Physgun", "Gravgun", "Toolgun/Properties", "Use (E)", "Damage" }
		for i = 1, 5 do
			local icon = top:Add("DImageButton")
			icon:SetSize(16, 16)
			icon:SetImage(string.format("icon16/%s.png", icons[i]))
			icon:SetTooltip(tips[i])
		end

		local color_outline = Color(100, 100, 100)
		local color_granted = Color(150, 255, 0)
		local color_revoked = Color(255, 0, 150)
		local color_global = Color(0, 150, 255)

		local plyElems = {}
		local globalElem

		local function playerBoxOnChange(self, checked)
			if self.ply:IsValid() then
				if checked then
					BSU.GrantPermission(self.ply, self.perm)
				else
					BSU.RevokePermission(self.ply, self.perm)
				end
			end
		end

		local function playerBoxPaint(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, color_outline)
			local globalBox = globalElem.boxes[self.idx]
			draw.RoundedBox(4, 1, 1, w - 2, h - 2, self:GetChecked() and (globalBox:GetChecked() and color_revoked or color_granted) or color_white)
		end

		local function updatePlayerElems()
			local oldElems = plyElems
			plyElems = {}
			for _, v in ipairs(player.GetHumans()) do
				if v == LocalPlayer() then continue end
				local oldElem = oldElems[v]
				if oldElem and oldElem:IsValid() then
					oldElem.name:SetText(v:Nick()) -- incase name changed
					plyElems[v] = oldElem
					oldElems[v] = nil
				else -- add player element
					local elem = list:Add("DIconLayout")
					plyElems[v] = elem
					elem.OwnLine = true
					elem:SetSize(225, 15)
					elem:SetSpaceX(10)

					local name = elem:Add("DLabel")
					elem.name = name
					name:SetSize(100, 15)
					name:SetText(v:Nick())
					name:SetColor(color_black)

					elem.boxes = {}
					for i = 1, 5 do
						local box = elem:Add("DCheckBox")
						elem.boxes[i] = box
						box.idx = i
						box.ply = v
						box.perm = bit.lshift(1, i - 1)
						box:SetValue(BSU.CheckPermission(v:SteamID64(), box.perm))
						box.OnChange = playerBoxOnChange
						box.Paint = playerBoxPaint
					end
				end
			end

			-- remove disconnected players elements
			for _, v in pairs(oldElems) do
				v:Remove()
			end
		end

		local function globalBoxOnChange(self, checked)
			if checked then
				BSU.GrantGlobalPermission(self.perm)
			else
				BSU.RevokeGlobalPermission(self.perm)
			end
		end

		local function globalBoxPaint(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, color_outline)
			draw.RoundedBox(4, 1, 1, w - 2, h - 2, self:GetChecked() and color_global or color_white)
		end

		local function updateGlobalElem()
			if globalElem and globalElem:IsValid() then return end

			local elem = list:Add("DIconLayout")
			globalElem = elem
			elem.OwnLine = true
			elem:SetSize(225, 15)
			elem:SetSpaceX(10)

			local name = elem:Add("DLabel")
			name:SetSize(100, 15)
			name:SetText("< Global >")
			name:SetColor(color_black)

			elem.boxes = {}
			for i = 1, 5 do
				local box = elem:Add("DCheckBox")
				elem.boxes[i] = box
				box.perm = bit.lshift(1, i - 1)
				box:SetValue(BSU.CheckGlobalPermission(box.perm))
				box.OnChange = globalBoxOnChange
				box.Paint = globalBoxPaint
			end
		end

		timer.Create("BSU_UpdatePropProtectionMenu", 1, 0, updatePlayerElems)

		hook.Add("BSU_ResetPermissions", "BSU_UpdatePropProtectionMenu", function()
			if globalElem then globalElem:Remove() end
			for _, elem in pairs(plyElems) do elem:Remove() end
			updateGlobalElem()
			updatePlayerElems()
		end)

		-- initialize elems
		updateGlobalElem()
		updatePlayerElems()

		pnl:CheckBox("Persist permissions across sessions", "bsu_permission_persist")
		pnl:CheckBox("Allow props to take fire damage", "bsu_allow_fire_damage")
	end)
end

hook.Add("PopulateToolMenu", "BSU_AddPropProtectionMenu", addPropProtectionMenu)

-- The prop info hud stuffffff
concommand.Add("bsu_propinfo_edit", function()
	if not BSU.PPHud then return end
	BSU.PPHud:MakeEditable(true)
end)

local font = "BSU_PP_HUD"
surface.CreateFont(font, {
	font = "Verdana",
	size = 18,
	weight = 400,
	antialias = true,
	shadow = true
})

local PPHud = {}

function PPHud:Init()
	self.cvarX = GetConVar("bsu_propinfo_x")
	self.cvarY = GetConVar("bsu_propinfo_y")
	self.cvarW = GetConVar("bsu_propinfo_w")
	self.cvarH = GetConVar("bsu_propinfo_h")

	self:SetSize(self.cvarW:GetInt(), self.cvarH:GetInt())
	self:SetPos(self.cvarX:GetInt(), self.cvarY:GetInt())
	self:SetDeleteOnClose(false)

	self.backgroundColor = Color(0, 0, 0, 150)

	self.isEditing = false

	local ownerLabel = vgui.Create("DLabel", self)
	ownerLabel:SetText("[Owner Name]")
	ownerLabel:SetFont(font)
	ownerLabel:SetTextColor(color_white)
	ownerLabel:Dock(TOP)
	self.ownerLabel = ownerLabel

	local modelLabel = vgui.Create("DLabel", self)
	modelLabel:SetText("[Model Name]")
	modelLabel:SetFont(font)
	modelLabel:SetTextColor(color_white)
	modelLabel:Dock(TOP)
	self.modelLabel = modelLabel

	local classLabel = vgui.Create("DLabel", self)
	classLabel:SetText("[Class Name]")
	classLabel:SetFont(font)
	classLabel:SetTextColor(color_white)
	classLabel:Dock(TOP)
	self.classLabel = classLabel

	self.editPaint = self.Paint
	self.hudPaint = function(s, w, h)
		local eyeTrace = LocalPlayer():GetEyeTrace()
		local viewEntity = eyeTrace.Entity
		local isValidEntity = IsValid(viewEntity) and not viewEntity:IsPlayer()

		s:SetAlpha(Lerp(RealFrameTime() * 25, s:GetAlpha(), isValidEntity and 255 or 0))
		s:SizeToChildren(true, true)

		if isValidEntity then
			s.modelLabel:SetText("Model: " .. viewEntity:GetModel())
			s.classLabel:SetText("Class: [" .. viewEntity:EntIndex() .. "] " .. viewEntity:GetClass())
			s.ownerLabel:SetText("Owner: " .. BSU.GetOwnerString(viewEntity))
		end

		draw.RoundedBox(4, 0, 20, w, h - 20, self.backgroundColor)
	end

	self:MakeEditable(false)
end

function PPHud:MakeEditable(b)
	self.isEditing = b

	self:SetDraggable(b)
	self:SetSizable(b)
	self:ShowCloseButton(b)
	self:SetTitle(b and "Edit Prop Info" or "")
	if b then
		self:SetAlpha(255)
		self.modelLabel:SetText("Model: [Model Name] [Model Name] [Model Name]")
		self.classLabel:SetText("Class: [Class Name] [Class Name] [Class Name]")
		self.ownerLabel:SetText("Owner: [Owner Name] [Owner Name] [Owner Name]")

		self:MakePopup()
	else
		self:SetMouseInputEnabled(false)
		self:SetKeyboardInputEnabled(false)
	end

	self.Paint = self.isEditing and self.editPaint or self.hudPaint
end

function PPHud:OnClose()
	self:Show()
	self:MakeEditable(false)

	self.cvarX:SetInt(self:GetX())
	self.cvarY:SetInt(self:GetY())
	self.cvarW:SetInt(self:GetWide())
	self.cvarH:SetInt(self:GetTall())
end

vgui.Register("BSUPPHud", PPHud, "DFrame")

cvars.AddChangeCallback("bsu_propinfo_enabled", function(_, _, new)
	if tobool(new) then
		if BSU.PPHud then BSU.PPHud:Remove() end
		BSU.PPHud = vgui.Create("BSUPPHud")
	else
		if BSU.PPHud then BSU.PPHud:Remove() end
	end
end)

hook.Add("InitPostEntity", "BSU_InitPPHud", function()
	if BSU.PPHud then BSU.PPHud:Remove() end
	BSU.PPHud = vgui.Create("BSUPPHud")
end)
-- End prop info hud stuffffff

if not GetConVar("bsu_permission_persist"):GetBool() then
	RunConsoleCommand("bsu_reset_permissions")
end

hook.Add("InitPostEntity", "BSU_SendPermissions", BSU.SendPermissions)
