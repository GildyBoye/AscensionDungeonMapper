AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper
DR.RouteHud = {}

local DEFAULT_W, DEFAULT_H = 420, 276
local ASPECT_RATIO = DEFAULT_W / DEFAULT_H
local MIN_W, MIN_H = 220, 220 / ASPECT_RATIO
local MINIMAP_SCALE = 1000

local hudFrame, hudContent, hudLevelPrev, hudLevelNext, hudMinimapBtn, hudMinimizeBtn

local hudInfo, hudMapKey, hudKnown
local hudDungeonKey, hudRouteName
local hudLevel
local hudLevels
local hudMinimized = false
local hudRestoreW, hudRestoreH = DEFAULT_W, DEFAULT_H

local minimapActive = false
local minimapBlips = {}
local minimapLineDotTexs = {}
local minimapTicker

local TOOLTIP_DELAY = 0.5

local function SetDelayedTooltip(widget, showFn)
	widget:SetScript("OnEnter", function(self)
		self.drTooltipElapsed = 0
		self:SetScript("OnUpdate", function(self, elapsed)
			self.drTooltipElapsed = self.drTooltipElapsed + elapsed
			if self.drTooltipElapsed >= TOOLTIP_DELAY then
				self:SetScript("OnUpdate", nil)
				showFn(self)
			end
		end)
	end)
	widget:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", nil)
		GameTooltip:Hide()
	end)
end

local function HudWingLevelRange()
	if hudInfo and hudInfo.level then
		return hudInfo.level, hudInfo.maxLevel or hudInfo.level
	end
	return nil, nil
end

local function UpdateHudLevelControls()
	local minLevel, maxLevel = HudWingLevelRange()
	local showControl
	if minLevel then
		showControl = maxLevel > minLevel
	else
		showControl = hudKnown and hudKnown.numLevels and hudKnown.numLevels > 1
	end
	if showControl then
		hudLevelPrev:Show()
		hudLevelNext:Show()
	else
		hudLevelPrev:Hide()
		hudLevelNext:Hide()
	end
end

local function RedrawHudRoute()
	if not hudLevels then return end
	local lvl = hudLevels[hudLevel] or { lines = {}, points = {} }
	DR.DrawEngine.RenderStatic(hudContent, hudContent:GetWidth(), hudContent:GetHeight(), lvl.lines, lvl.points, 2, 12)
end

local function ClearMinimapBlips()
	for _, tex in ipairs(minimapBlips) do tex:Hide() end
	for _, tex in ipairs(minimapLineDotTexs) do tex:Hide() end
end

local function UpdateMinimapBlips()
	if not minimapActive or not hudKnown or not hudLevels then
		ClearMinimapBlips()
		return
	end
	local lvl = hudLevels[hudLevel]
	if not lvl then
		ClearMinimapBlips()
		return
	end

	local skipped, px, py = DR.WithSavedMapState(function()
		SetMapByID(hudKnown.mapID)
		local dungeonLevel = hudLevel
		if DungeonUsesTerrainMap() then dungeonLevel = dungeonLevel - 1 end
		if dungeonLevel > 0 then SetDungeonMapLevel(dungeonLevel) end
		return GetPlayerMapPosition("player")
	end)

	if skipped or not px or (px == 0 and py == 0) then
		ClearMinimapBlips()
		return
	end

	local radius = math.min(Minimap:GetWidth(), Minimap:GetHeight()) / 2 - 6
	local rotate = GetCVar("rotateMinimap") == "1"
	local facing = rotate and (GetPlayerFacing() or 0) or 0
	local cosF, sinF = math.cos(facing), math.sin(facing)

	local function ProjectRaw(x, y)
		local dx, dy = (x - px) * MINIMAP_SCALE, (y - py) * MINIMAP_SCALE
		if rotate then
			local rdx = dx * cosF - dy * sinF
			local rdy = dx * sinF + dy * cosF
			dx, dy = rdx, rdy
		end
		return dx, dy
	end

	local function Project(x, y)
		local dx, dy = ProjectRaw(x, y)
		local dist = math.sqrt(dx * dx + dy * dy)
		if dist > radius then
			local shrink = radius / dist
			dx, dy = dx * shrink, dy * shrink
		end
		return dx, dy
	end

	local function ClipSegmentToCircle(x1, y1, x2, y2)
		local dx, dy = x2 - x1, y2 - y1
		local a = dx * dx + dy * dy
		if a < 1e-6 then
			if x1 * x1 + y1 * y1 <= radius * radius then
				return x1, y1, x2, y2
			end
			return nil
		end
		local b = 2 * (x1 * dx + y1 * dy)
		local c = x1 * x1 + y1 * y1 - radius * radius
		local disc = b * b - 4 * a * c
		if disc < 0 then return nil end
		local sqrtDisc = math.sqrt(disc)
		local t1 = (-b - sqrtDisc) / (2 * a)
		local t2 = (-b + sqrtDisc) / (2 * a)
		local tStart = math.max(0, t1)
		local tEnd = math.min(1, t2)
		if tStart >= tEnd then return nil end
		return x1 + tStart * dx, y1 + tStart * dy, x1 + tEnd * dx, y1 + tEnd * dy
	end

	local dotCount = 0
	local function PlaceDot(x, y)
		dotCount = dotCount + 1
		local tex = minimapLineDotTexs[dotCount]
		if not tex then
			tex = Minimap:CreateTexture(nil, "ARTWORK")
			tex:SetTexture(1, 0.85, 0.1, 0.9)
			tex:SetWidth(2)
			tex:SetHeight(2)
			minimapLineDotTexs[dotCount] = tex
		end
		tex:ClearAllPoints()
		tex:SetPoint("CENTER", Minimap, "CENTER", x, -y)
		tex:Show()
	end

	for _, l in ipairs(lvl.lines or {}) do
		local x1, y1, x2, y2 = DR.DrawEngine.NormalizeLineData(l)
		local rx1, ry1 = ProjectRaw(x1, y1)
		local rx2, ry2 = ProjectRaw(x2, y2)
		local cx1, cy1, cx2, cy2 = ClipSegmentToCircle(rx1, ry1, rx2, ry2)

		if cx1 then
			local ddx, ddy = cx2 - cx1, cy2 - cy1
			local segLength = math.sqrt(ddx * ddx + ddy * ddy)
			local steps = math.max(1, math.ceil(segLength / 3))
			for i = 0, steps do
				local t = i / steps
				PlaceDot(cx1 + ddx * t, cy1 + ddy * t)
			end
		end
	end
	for i = dotCount + 1, #minimapLineDotTexs do
		minimapLineDotTexs[i]:Hide()
	end

	local pointCount = 0
	for _, p in ipairs(lvl.points or {}) do
		local x, y = DR.DrawEngine.NormalizePointData(p)
		local dx, dy = Project(x, y)

		pointCount = pointCount + 1
		local tex = minimapBlips[pointCount]
		if not tex then
			tex = Minimap:CreateTexture(nil, "OVERLAY")
			tex:SetWidth(8)
			tex:SetHeight(8)
			tex:SetTexture(1, 0.85, 0.1, 0.95)
			minimapBlips[pointCount] = tex
		end
		tex:ClearAllPoints()
		tex:SetPoint("CENTER", Minimap, "CENTER", dx, -dy)
		tex:Show()
	end
	for i = pointCount + 1, #minimapBlips do
		minimapBlips[i]:Hide()
	end
end

local function SetMinimapOverlay(active)
	local wasActive = minimapActive
	minimapActive = active
	if active then
		if not minimapTicker then
			minimapTicker = CreateFrame("Frame")
			local mmElapsed = 0
			minimapTicker:SetScript("OnUpdate", function(self, elapsed)
				mmElapsed = mmElapsed + elapsed
				if mmElapsed < 0.2 then return end
				mmElapsed = 0
				UpdateMinimapBlips()
			end)
		end
		minimapTicker:Show()
		UpdateMinimapBlips()
		DR.Print("Minimap route overlay is ON (markers and lines). This is an approximation (no real distance data for custom dungeons) -- expect drift, wrong scale, warped lines, or issues if you have minimap rotation enabled.")
	else
		if minimapTicker then minimapTicker:Hide() end
		ClearMinimapBlips()
		if wasActive then
			DR.Print("Minimap route overlay is OFF.")
		end
	end
	if hudMinimapBtn then
		if active then
			hudMinimapBtn:LockHighlight()
		else
			hudMinimapBtn:UnlockHighlight()
		end
	end
end

local function ShowHudLevel(level)
	hudLevel = level
	DR.MapTexture.Build(hudContent, hudMapKey, hudLevel)
	RedrawHudRoute()
	UpdateHudLevelControls()
end

local function ChangeHudLevel(delta)
	if not hudKnown or not hudKnown.numLevels or hudKnown.numLevels <= 1 then return end
	local minLevel, maxLevel = HudWingLevelRange()
	minLevel, maxLevel = minLevel or 1, maxLevel or hudKnown.numLevels
	local newLevel = hudLevel + delta
	if newLevel < minLevel or newLevel > maxLevel then return end
	ShowHudLevel(newLevel)
end

local function SaveHudGeometry()
	if not hudFrame then return end
	local point, _, relPoint, x, y = hudFrame:GetPoint()
	if not point then return end
	local w = hudMinimized and hudRestoreW or hudFrame:GetWidth()
	local h = hudMinimized and hudRestoreH or hudFrame:GetHeight()
	DR.db.routeHud = { point = point, relPoint = relPoint, x = x, y = y, width = w, height = h }
end

local function BuildHudFrame()
	local f = CreateFrame("Frame", "AscensionDungeonMapperRouteHud", UIParent)
	local saved = DR.db.routeHud
	if saved and saved.point and saved.width and saved.height then
		f:SetWidth(math.max(saved.width, MIN_W))
		f:SetHeight(math.max(saved.height, MIN_H))
		f:SetPoint(saved.point, UIParent, saved.relPoint or saved.point, saved.x, saved.y)
	else
		f:SetWidth(DEFAULT_W)
		f:SetHeight(DEFAULT_H)
		f:SetPoint("BOTTOMRIGHT", UIParent, "CENTER", 300 + DEFAULT_W, -(100 + DEFAULT_H))
	end
	f:SetFrameStrata("MEDIUM")
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetResizable(true)
	f:SetMinResize(MIN_W, MIN_H)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", function()
		f:StopMovingOrSizing()
		SaveHudGeometry()
	end)
	f:Hide()

	hudContent = CreateFrame("Frame", nil, f)
	hudContent:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	hudContent:SetWidth(DEFAULT_W)
	hudContent:SetHeight(DEFAULT_H)

	local adjustingSize = false
	f:SetScript("OnSizeChanged", function(self, width, height)
		if adjustingSize or hudMinimized then return end
		local targetHeight = width / ASPECT_RATIO
		if math.abs(height - targetHeight) > 0.5 then
			adjustingSize = true
			self:SetHeight(targetHeight)
			adjustingSize = false
			return
		end

		hudContent:SetWidth(width)
		hudContent:SetHeight(height)
		if hudMapKey then
			DR.MapTexture.Build(hudContent, hudMapKey, hudLevel)
		end
		RedrawHudRoute()
	end)

	local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	closeBtn:SetWidth(20)
	closeBtn:SetHeight(20)
	closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", 2, 2)
	closeBtn:SetFrameLevel(f:GetFrameLevel() + 15)
	closeBtn:SetScript("OnClick", function()
		SetMinimapOverlay(false)
		f:Hide()
	end)
	SetDelayedTooltip(closeBtn, function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("Close the route HUD", 1, 1, 1)
		GameTooltip:Show()
	end)

	hudMinimizeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	hudMinimizeBtn:SetWidth(20)
	hudMinimizeBtn:SetHeight(20)
	hudMinimizeBtn:SetText("_")
	hudMinimizeBtn:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)
	hudMinimizeBtn:SetFrameLevel(f:GetFrameLevel() + 15)
	hudMinimizeBtn:SetScript("OnClick", function()
		hudMinimized = not hudMinimized
		if hudMinimized then
			hudRestoreW, hudRestoreH = f:GetWidth(), f:GetHeight()
			hudContent:Hide()
			f:SetWidth(140)
			f:SetHeight(24)
			hudMinimizeBtn:SetText("+")
		else
			hudContent:Show()
			f:SetWidth(hudRestoreW)
			f:SetHeight(hudRestoreH)
			hudMinimizeBtn:SetText("_")
		end
	end)
	SetDelayedTooltip(hudMinimizeBtn, function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("Minimize/restore the HUD", 1, 1, 1)
		GameTooltip:Show()
	end)

	hudMinimapBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	hudMinimapBtn:SetWidth(20)
	hudMinimapBtn:SetHeight(20)
	hudMinimapBtn:SetText("M")
	hudMinimapBtn:SetPoint("RIGHT", hudMinimizeBtn, "LEFT", -2, 0)
	hudMinimapBtn:SetFrameLevel(f:GetFrameLevel() + 15)
	hudMinimapBtn:SetScript("OnClick", function() SetMinimapOverlay(not minimapActive) end)
	SetDelayedTooltip(hudMinimapBtn, function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("Show route markers on the minimap", 1, 1, 1)
		GameTooltip:AddLine("Approximate only, not exact yards -- may drift, be off-scale, or misbehave with minimap rotation enabled.", 0.9, 0.6, 0.2, true)
		GameTooltip:Show()
	end)

	local resizeGrip = CreateFrame("Button", nil, hudContent)
	resizeGrip:SetWidth(16)
	resizeGrip:SetHeight(16)
	resizeGrip:SetPoint("TOPLEFT", hudContent, "TOPLEFT", 0, 0)
	resizeGrip:SetFrameLevel(hudContent:GetFrameLevel() + 10)
	local gripTex = resizeGrip:CreateTexture(nil, "OVERLAY")
	gripTex:SetAllPoints(resizeGrip)
	gripTex:SetTexture(1, 1, 1, 0.35)
	resizeGrip:SetScript("OnMouseDown", function() f:StartSizing("TOPLEFT") end)
	resizeGrip:SetScript("OnMouseUp", function()
		f:StopMovingOrSizing()
		SaveHudGeometry()
	end)
	SetDelayedTooltip(resizeGrip, function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Drag to resize", 1, 1, 1)
		GameTooltip:AddLine("Aspect ratio is locked.", 0.9, 0.9, 0.9, true)
		GameTooltip:Show()
	end)

	hudLevelPrev = CreateFrame("Button", nil, hudContent, "UIPanelButtonTemplate")
	hudLevelPrev:SetWidth(20)
	hudLevelPrev:SetHeight(20)
	hudLevelPrev:SetText("<")
	hudLevelPrev:SetPoint("BOTTOMLEFT", hudContent, "BOTTOMLEFT", 2, 2)
	hudLevelPrev:SetFrameLevel(hudContent:GetFrameLevel() + 10)
	hudLevelPrev:SetScript("OnClick", function() ChangeHudLevel(-1) end)
	SetDelayedTooltip(hudLevelPrev, function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText("Previous level", 1, 1, 1)
		GameTooltip:Show()
	end)

	hudLevelNext = CreateFrame("Button", nil, hudContent, "UIPanelButtonTemplate")
	hudLevelNext:SetWidth(20)
	hudLevelNext:SetHeight(20)
	hudLevelNext:SetFrameLevel(hudContent:GetFrameLevel() + 10)
	hudLevelNext:SetText(">")
	hudLevelNext:SetPoint("LEFT", hudLevelPrev, "RIGHT", 4, 0)
	hudLevelNext:SetScript("OnClick", function() ChangeHudLevel(1) end)
	SetDelayedTooltip(hudLevelNext, function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText("Next level", 1, 1, 1)
		GameTooltip:Show()
	end)

	return f
end

local function BestRouteName(dungeonKey)
	return DR.BestRouteNameForDungeon(dungeonKey)
end

local function ShowRouteHud(dungeonKey)
	local routeName = BestRouteName(dungeonKey)
	if not routeName then return end
	local data = DR.GetRoutesForDungeon(dungeonKey)[routeName]

	hudInfo = DR.DungeonByKey[dungeonKey]
	hudMapKey = hudInfo.parentKey or dungeonKey
	hudKnown = DR.GetKnownMap(hudMapKey)
	hudLevels = DR.NormalizeRouteLevels(data)
	hudDungeonKey = dungeonKey
	hudRouteName = routeName

	if not hudFrame then
		hudFrame = BuildHudFrame()
	end

	ShowHudLevel(data.level or hudInfo.level or 0)
	hudFrame:Show()
end

local function ResolveCurrentDungeonKey()
	local inInstance, instanceType = IsInInstance()
	if not inInstance or (instanceType ~= "party" and instanceType ~= "raid") then
		return nil
	end
	local name = GetInstanceInfo()
	return DR.KeyByNormalizedName[DR.NormalizeName(name)]
end

function DR.RouteHud.ShowOrRefresh()
	local key = ResolveCurrentDungeonKey()
	if not key then
		DR.Print("Not currently in a dungeon this addon recognizes.")
		return
	end
	local routeName = BestRouteName(key)
	if not routeName then
		DR.Print("No saved route for this dungeon yet.")
		return
	end
	ShowRouteHud(key)
end

function DR.RouteHud.NotifyRouteChanged(dungeonKey)
	if not hudFrame or not hudFrame:IsShown() or hudDungeonKey ~= dungeonKey then return end
	local routeName = BestRouteName(dungeonKey)
	if routeName then
		ShowRouteHud(dungeonKey)
	else
		SetMinimapOverlay(false)
		hudFrame:Hide()
	end
end

DR.DrawEngine.AddChangeListener(function()
	if not hudFrame or not hudFrame:IsShown() or not hudDungeonKey then return end
	if not DR.UI.GetOpenRoute then return end
	local editDungeonKey, editRouteName, editLevel = DR.UI.GetOpenRoute()
	if editDungeonKey ~= hudDungeonKey or editRouteName ~= hudRouteName then return end

	local lines, points = DR.DrawEngine.GetRouteData()
	hudLevels[editLevel] = { lines = lines, points = points }
	if editLevel == hudLevel then
		RedrawHudRoute()
	end
end)

local function CheckAndShowHud()
	local key = ResolveCurrentDungeonKey()
	if key then
		if DR.db.autoHud == false then return end
		ShowRouteHud(key)
	elseif hudFrame then
		SetMinimapOverlay(false)
		hudFrame:Hide()
	end
end

local levelTrackerElapsed = 0
local levelTracker = CreateFrame("Frame")
levelTracker:SetScript("OnUpdate", function(self, elapsed)
	levelTrackerElapsed = levelTrackerElapsed + elapsed
	if levelTrackerElapsed < 1 then return end
	levelTrackerElapsed = 0

	if not hudFrame or not hudFrame:IsShown() or not hudKnown then return end
	if HudWingLevelRange() then return end
	if not hudKnown.numLevels or hudKnown.numLevels <= 1 then return end

	local skipped, actualLevel = DR.WithSavedMapState(function()
		SetMapToCurrentZone()
		local lvl = GetCurrentMapDungeonLevel()
		if DungeonUsesTerrainMap() then
			lvl = lvl + 1
		end
		return lvl
	end)

	if skipped or not actualLevel or actualLevel <= 0 then return end
	if actualLevel ~= hudLevel then
		ShowHudLevel(actualLevel)
	end
end)

local settleFrame = CreateFrame("Frame")
settleFrame:Hide()
settleFrame:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed < 1.5 then return end
	self:Hide()
	CheckAndShowHud()
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
	settleFrame.elapsed = 0
	settleFrame:Show()
end)
