local PANEL = {}

local propinfo_x = GetConVar("bsu_propinfo_x")
local propinfo_y = GetConVar("bsu_propinfo_y")
local propinfo_enabled = GetConVar("bsu_propinfo_enabled")

local font = "TargetIDSmall"
local color_bg = Color(0, 0, 0, 80)

local isHoldingCamera = true

PANEL.AlphaMultiplier = 0
PANEL.AlphaTarget = 0
PANEL.InContextMenu = false

function PANEL:Init()
	self:SetSize(0, 0)
	self:SetCursor("sizeall")
	self:OnScreenSizeChanged()

	self.Lines = {}
	self.Colors = {}

	hook.Add("OnScreenSizeChanged", self, self.OnScreenSizeChanged)
	hook.Add("ContextMenuOpened", self, self.ContextMenuOpened)
	hook.Add("ContextMenuClosed", self, self.ContextMenuClosed)
end

function PANEL:OnScreenSizeChanged()
	self:SetPos(
		math.Round(math.Clamp(propinfo_x:GetFloat(), 0, 1) * ScrW()),
		math.Round(math.Clamp(propinfo_y:GetFloat(), 0, 1) * ScrH())
	)
end

function PANEL:ContextMenuOpened()
	self.InContextMenu = true
	self:SetParent(g_ContextMenu)
end

function PANEL:ContextMenuClosed()
	self.InContextMenu = false
	self:SetParent(vgui.GetWorldPanel())
end

function PANEL:OnMousePressed()
	self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
	self:MouseCapture(true)
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self:MouseCapture(false)

	local x = self:GetX()
	local y = self:GetY()

	local w = self:GetWide()
	local h = self:GetTall()

	local sw = ScrW()
	local sh = ScrH()

	if self.x + w / 2 >= sw / 2 then x = x + w end
	y = y + h / 2

	propinfo_x:SetFloat(x / sw)
	propinfo_y:SetFloat(y / sh)
end

local TraceLine = util.LegacyTraceLine or util.TraceLine -- incase a baddon overwrites it

local color_server = Color(152, 212, 255)
local color_client = Color(232, 220, 117)

function PANEL:Think()
	local ply = LocalPlayer()
	if not ply:IsValid() then return end

	local data = util.GetPlayerTrace(ply)
	data.mask = MASK_SHOT -- fix not hitting debris entities
	data.hitclientonly = true

	local tr = TraceLine(data)
	if not tr then return end -- too early

	local ent = tr.Entity
	if not IsValid(ent) then
		data.hitclientonly = nil
		tr = TraceLine(data)
		ent = tr.Entity
	end

	local w = self:GetWide()
	local h = self:GetTall()

	local sw = ScrW()
	local sh = ScrH()

	if ent:IsValid() and not ent:IsPlayer() or ent:IsWorld() and self.InContextMenu then
		local cl_tostring = tostring(ent)
		local sv_tostring = ent:BSU_GetServerToString()

		local serverside = input.IsKeyDown(KEY_LSHIFT)

		self.Lines = {
			cl_tostring ~= sv_tostring and serverside and sv_tostring or cl_tostring,
			ent:GetModel(),
			{ BSU.GetOwnerString(ent) }
		}

		self.Colors = {
			cl_tostring ~= sv_tostring and (serverside and color_server or color_client) or nil,
			nil,
			{ BSU.GetOwnerColor(ent) }
		}

		-- update size
		w = 0
		h = 0

		surface.SetFont(font)

		for _, v in ipairs(self.Lines) do
			local tw = surface.GetTextSize(istable(v) and table.concat(v) or v)
			w = math.max(w, tw)
			h = h + 20
		end

		w = w + 8
		h = h + 8

		local dw = self:GetWide() - w
		local dh = self:GetTall() - h

		self:SetSize(w, h)

		-- fix position if on right side of screen
		if self.x + w / 2 >= sw / 2 then
			self:SetX(self.x + dw)
			if self.Dragging then self.Dragging[1] = self.Dragging[1] - dw end
		end

		self:SetY(self.y + dh / 2)

		self.AlphaTarget = 1
	end

	local fadein = self.AlphaTarget > 0
	self.AlphaMultiplier = Lerp(RealFrameTime() * 15, self.AlphaMultiplier, self.AlphaTarget)
	if fadein and math.abs(self.AlphaMultiplier - self.AlphaTarget) < 1e-5 then
		self.AlphaTarget = 0
	end

	if not self.Dragging then return end

	local x = gui.MouseX() - self.Dragging[1]
	local y = gui.MouseY() - self.Dragging[2]

	if input.IsKeyDown(KEY_LSHIFT) then
		x = math.Round(x / (sw / 16)) * (sw / 16)
		y = y + h / 2
		y = math.Round(y / (sh / 16)) * (sh / 16)
		y = y - h / 2
	end

	x = math.Clamp(x, 0, sw - w)
	y = math.Clamp(y, 0, sh - h)

	self:SetPos(x, y)
end

function PANEL:Paint(w, h)
	if isHoldingCamera then return end

	local left = self.x + w / 2 < ScrW() / 2
	local x = left and 4 or w - 4
	local align = left and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT

	surface.SetAlphaMultiplier(self.AlphaMultiplier)

	draw.RoundedBox(4, 0, 0, w, h, color_bg)

	local lines = self.Lines
	local colors = self.Colors

	for k, line in ipairs(lines) do
		local y = k * 20 - 10 + 4
		if istable(line) then
			surface.SetFont(font)
			local tw = 0
			if left then
				for j = 1, #line do
					local text = line[j]
					draw.SimpleText(text, font, x + tw, y, colors[k][j], align, TEXT_ALIGN_CENTER)
					tw = tw + surface.GetTextSize(text)
				end
			else
				for j = #line, 1, -1 do
					local text = line[j]
					draw.SimpleText(text, font, x - tw, y, colors[k][j], align, TEXT_ALIGN_CENTER)
					tw = tw + surface.GetTextSize(text)
				end
			end
		else
			draw.SimpleText(line, font, x, y, colors[k], align, TEXT_ALIGN_CENTER)
		end
	end

	surface.SetAlphaMultiplier(1)
end

local function CreatePropInfoPanel(_, _, enabled)
	if IsValid(BSU.PropInfo) then BSU.PropInfo:Remove() end
	if tobool(enabled) then BSU.PropInfo = vgui.Create("BSU_PropInfo") end
end

hook.Add("HUDPaint", "BSU_PropInfo", function()
	isHoldingCamera = false
end)

hook.Add("PostRender", "BSU_PropInfo", function()
	isHoldingCamera = true
end)

hook.Add("OnGamemodeLoaded", "BSU_PropInfo", function()
	local isEnabled = propinfo_enabled:GetInt()
	CreatePropInfoPanel(nil, nil, isEnabled)
end)

cvars.AddChangeCallback("bsu_propinfo_enabled", CreatePropInfoPanel)

vgui.Register("BSU_PropInfo", PANEL, "DPanel")
