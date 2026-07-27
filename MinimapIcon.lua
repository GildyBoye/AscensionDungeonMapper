-- AscensionDungeonMapper MinimapIcon
-- A small draggable button on the minimap ring that toggles the main window.
-- Built by hand (no LibDBIcon/LibDataBroker dependency) since all we need is
-- a single button, not a pluggable multi-addon icon row.

AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper

local ICON_SIZE = 31
local button

local function GetAngleRadians()
	return math.rad(DR.db.minimapIcon.angle or 200)
end

local function UpdateButtonPosition()
	local radius = (Minimap:GetWidth() / 2) + 5
	local angle = GetAngleRadians()
	local x = math.cos(angle) * radius
	local y = math.sin(angle) * radius
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function SetAngleFromCursor()
	local scale = Minimap:GetEffectiveScale()
	local cx, cy = GetCursorPosition()
	cx, cy = cx / scale, cy / scale
	local mx, my = Minimap:GetCenter()
	local angle = math.atan2(cy - my, cx - mx)
	DR.db.minimapIcon.angle = math.deg(angle)
	UpdateButtonPosition()
end

local function BuildButton()
	local b = CreateFrame("Button", "AscensionDungeonMapperMinimapButton", Minimap)
	b:SetWidth(ICON_SIZE)
	b:SetHeight(ICON_SIZE)
	b:SetFrameStrata("MEDIUM")
	b:SetFrameLevel(8)
	b:RegisterForClicks("LeftButtonUp")
	b:RegisterForDrag("LeftButton")

	local icon = b:CreateTexture(nil, "BACKGROUND")
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetPoint("CENTER", b, "CENTER", 0, 1)
	-- Crop the icon inward a touch so it reads cleanly inside the round border.
	icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	b.icon = icon

	-- MinimapButtonBorder is the square-ish frame used for chrome like the
	-- mail/calendar icons; the round gold ring every third-party addon's
	-- minimap button uses (via LibDBIcon-1.0 etc.) is MiniMap-TrackingBorder.
	local border = b:CreateTexture(nil, "OVERLAY")
	border:SetWidth(53)
	border:SetHeight(53)
	border:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

	local highlight = b:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetWidth(20)
	highlight:SetHeight(20)
	highlight:SetPoint("CENTER", b, "CENTER", 0, 1)
	highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	highlight:SetBlendMode("ADD")

	b:SetScript("OnClick", function()
		if DR.ToggleMainFrame then
			DR.ToggleMainFrame()
		end
	end)

	b:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", SetAngleFromCursor)
	end)
	b:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	b:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("Ascension Dungeon Mapper", 1, 1, 1)
		GameTooltip:AddLine("Click to open", 0.9, 0.9, 0.9)
		GameTooltip:AddLine("Drag to move", 0.9, 0.9, 0.9)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)

	return b
end

function DR.InitMinimapIcon()
	DR.db.minimapIcon = DR.db.minimapIcon or { angle = 200 }
	if not button then
		button = BuildButton()
	end
	UpdateButtonPosition()
end
