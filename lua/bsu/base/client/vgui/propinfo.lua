local PANEL = {}

local propinfo_x = GetConVar("bsu_propinfo_x")
local propinfo_y = GetConVar("bsu_propinfo_y")
local propinfo_enabled = GetConVar("bsu_propinfo_enabled")

local font = "TargetIDSmall"
local color_bg = Color(0, 0, 0, 80)

local isHoldingCamera = false

PANEL.AlphaMultiplier = 0
PANEL.AlphaTarget = 0
PANEL.InContextMenu = false

function PANEL:Init()
	self:SetSize(0, 0)
	self:SetCursor("sizeall")
	self:OnScreenSizeChanged()

	self.Text = {}

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

function PANEL:Think()
	local ply = LocalPlayer()
	if not ply:IsValid() then return end

	local tr = util.GetPlayerTrace(ply)
	tr.mask = MASK_SHOT -- fix not hitting some entities
	tr = util.TraceLine(tr)
	if not tr then return end

	local w = self:GetWide()
	local h = self:GetTall()

	local sw = ScrW()
	local sh = ScrH()

	local ent = tr.Entity
	if ent:IsValid() and not ent:IsPlayer() or ent:IsWorld() and self.InContextMenu then
		self.Text = {
			tostring(ent),
			ent:GetModel(),
			BSU.GetOwnerString(ent)
		}

		-- update size

		w = 0
		h = 0

		surface.SetFont(font)

		for _, v in ipairs(self.Text) do
			local tw = surface.GetTextSize(v)
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

	for k, v in ipairs(self.Text) do
		local y = k * 20 - 10 + 4
		draw.SimpleText(v, font, x, y, nil, align, TEXT_ALIGN_CENTER)
	end

	surface.SetAlphaMultiplier(1)
end

local function createPropInfoPanel(_, _, enabled)
	if IsValid(BSU.PropInfo) then BSU.PropInfo:Remove() end
	if tobool(enabled) then BSU.PropInfo = vgui.Create("BSU_PropInfo") end
end

hook.Add("Think", "BSU_ShouldHideHUD", function()
	local activeWeapon = LocalPlayer():GetActiveWeapon()
	if not IsValid(activeWeapon) then
		isHoldingCamera = false
		return
	end
	isHoldingCamera = activeWeapon:GetClass() == "gmod_camera"
end)

hook.Add("OnGamemodeLoaded", "BSU_PropInfo", function()
	local isEnabled = propinfo_enabled:GetInt()
	createPropInfoPanel(nil, nil, isEnabled)
end)

cvars.AddChangeCallback("bsu_propinfo_enabled", createPropInfoPanel)

vgui.Register("BSU_PropInfo", PANEL, "DPanel")
