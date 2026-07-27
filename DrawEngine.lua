-- AscensionDungeonMapper DrawEngine
--
-- Handles freehand-drawing route strokes and point markers on a canvas frame,
-- storing everything in normalized (0..1) coordinates so it's independent of
-- the canvas's actual pixel size. Strokes are rendered as a run of short
-- straight segments sampled while the mouse button is held, using
-- Texture:SetRotation() per segment -- confirmed available in the 3.3.5
-- client (Blizzard's own WorldMapFrame.lua uses it for the player arrow icon).

AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper
DR.DrawEngine = {}
local Draw = DR.DrawEngine

local LINE_THICKNESS = 3
local DEFAULT_LINE_COLOR = { 0.2, 0.55, 0.95, 0.95 }
local POINT_SIZE = 14
local POINT_COLOR = { 0.95, 0.25, 0.2, 1 }

-- Selectable palette for the Draw tool (picker shown in UI.lua while
-- drawing is active). Alpha is fixed; only RGB is chosen.
local LINE_COLORS = {
	{ 0.2, 0.55, 0.95 },  -- Blue (default)
	{ 0.9, 0.2, 0.2 },    -- Red
	{ 0.25, 0.85, 0.35 }, -- Green
	{ 0.95, 0.85, 0.15 }, -- Yellow
	{ 0.65, 0.35, 0.9 },  -- Purple
	{ 0.95, 0.55, 0.15 }, -- Orange
	{ 0.95, 0.95, 0.95 }, -- White
}
Draw.LINE_COLORS = LINE_COLORS

-- Color new strokes are drawn in. Changing it doesn't affect strokes already
-- on the canvas -- CreateLineWidget snapshots whatever this is at creation
-- time into the widget's own entry.color.
local currentLineColor = DEFAULT_LINE_COLOR

-- A fresh table each call so previously-stored entry.color references
-- aren't retroactively mutated by a later color change.
function Draw.SetLineColor(r, g, b)
	currentLineColor = { r, g, b, DEFAULT_LINE_COLOR[4] }
end

-- Minimum cursor movement (normalized) before a freehand stroke lays down
-- another segment -- keeps texture count reasonable on a long drag while
-- still reading as a smooth continuous line.
local MIN_SEGMENT_DIST = 0.008

-- Erase-mode click tolerance, in canvas pixels, for "is this click on a
-- drawn stroke" hit-testing.
local ERASE_TOLERANCE_PX = 6

local canvas -- the active canvas frame
local mode -- nil | "line" | "point" | "erase"
local history = {} -- undo stack: entries are {kind="stroke", strokeId=...} or {kind="point", entry=...}

local lineWidgets = {}  -- array of {tex=Texture, x1,y1,x2,y2, strokeId}
local pointWidgets = {} -- array of {frame=Frame, x, y, title, text}

local nextStrokeId = 0
local function AllocateStrokeId()
	nextStrokeId = nextStrokeId + 1
	return nextStrokeId
end

-- In-progress stroke state (mode == "line", mouse button held) --------------
local painting = false
local currentStrokeId
local strokeHasSegment
local lastX, lastY

-- Coordinate helpers ---------------------------------------------------

local function GetNormalizedCursorPos()
	local scale = canvas:GetEffectiveScale()
	local cx, cy = GetCursorPosition()
	cx, cy = cx / scale, cy / scale
	local left, top = canvas:GetLeft(), canvas:GetTop()
	local relX = cx - left
	local relY = top - cy
	return relX / canvas:GetWidth(), relY / canvas:GetHeight()
end

local function ClampNorm(v)
	if v < 0 then return 0 end
	if v > 1 then return 1 end
	return v
end

-- Line rendering ---------------------------------------------------------

local function PositionLineTexture(tex, x1, y1, x2, y2)
	local w, h = canvas:GetWidth(), canvas:GetHeight()
	local px1, py1 = x1 * w, y1 * h
	local px2, py2 = x2 * w, y2 * h
	local midx, midy = (px1 + px2) / 2, (py1 + py2) / 2
	local dx, dy = px2 - px1, py2 - py1
	local length = math.sqrt(dx * dx + dy * dy)
	if length < 1 then length = 1 end
	local angle = math.atan2(-dy, dx)

	tex:ClearAllPoints()
	tex:SetPoint("CENTER", canvas, "TOPLEFT", midx, -midy)
	tex:SetWidth(length)
	tex:SetHeight(LINE_THICKNESS)
	tex:SetRotation(angle)
end

local function CreateLineWidget(x1, y1, x2, y2, strokeId, color)
	color = color or DEFAULT_LINE_COLOR
	local tex = canvas:CreateTexture(nil, "OVERLAY")
	tex:SetTexture(color[1], color[2], color[3], color[4])
	PositionLineTexture(tex, x1, y1, x2, y2)
	local entry = { tex = tex, x1 = x1, y1 = y1, x2 = x2, y2 = y2, strokeId = strokeId, color = color }
	lineWidgets[#lineWidgets + 1] = entry
	return entry
end

-- Distance (in canvas pixels) from a normalized point to a normalized
-- segment -- used for erase-mode hit-testing, since a rotated Texture can't
-- take clicks on its own and a freehand path is too irregular for a simple
-- bounding-box button per segment.
local function DistPointToSegmentPx(px, py, x1, y1, x2, y2)
	local w, h = canvas:GetWidth(), canvas:GetHeight()
	px, py = px * w, py * h
	x1, y1 = x1 * w, y1 * h
	x2, y2 = x2 * w, y2 * h
	local dx, dy = x2 - x1, y2 - y1
	local lenSq = dx * dx + dy * dy
	local t
	if lenSq < 1e-6 then
		t = 0
	else
		t = ((px - x1) * dx + (py - y1) * dy) / lenSq
		if t < 0 then t = 0 elseif t > 1 then t = 1 end
	end
	local cx, cy = x1 + t * dx, y1 + t * dy
	local ddx, ddy = px - cx, py - cy
	return math.sqrt(ddx * ddx + ddy * ddy)
end

local function FindNearestStrokeId(x, y)
	local bestId, bestDist = nil, ERASE_TOLERANCE_PX
	for _, l in ipairs(lineWidgets) do
		local d = DistPointToSegmentPx(x, y, l.x1, l.y1, l.x2, l.y2)
		if d <= bestDist then
			bestDist = d
			bestId = l.strokeId
		end
	end
	return bestId
end

-- Point rendering ---------------------------------------------------------

-- The 8 built-in raid target markers, in Blizzard's standard 1-8 order
-- (Star, Circle, Diamond, Triangle, Moon, Square, Cross, Skull). Every
-- client ships these -- no custom art to bundle.
local RAID_ICONS = {
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
}
Draw.RAID_ICONS = RAID_ICONS

local function PositionPointFrame(frame, x, y)
	local w, h = canvas:GetWidth(), canvas:GetHeight()
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", canvas, "TOPLEFT", x * w, -(y * h))
end

local function CreatePointWidget(x, y, title, text, icon)
	local frame = CreateFrame("Button", nil, canvas)
	frame:SetWidth(POINT_SIZE)
	frame:SetHeight(POINT_SIZE)
	PositionPointFrame(frame, x, y)

	local tex = frame:CreateTexture(nil, "OVERLAY")
	tex:SetAllPoints(frame)
	frame.dr_tex = tex

	local border = frame:CreateTexture(nil, "OVERLAY", nil, 1)
	border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
	border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
	border:SetTexture(0, 0, 0, 1)
	frame:SetFrameLevel(canvas:GetFrameLevel() + 2)
	border:SetDrawLayer("OVERLAY", 0)
	tex:SetDrawLayer("OVERLAY", 1)

	local entry = { frame = frame, x = x, y = y, title = title or "", text = text or "", icon = icon }

	-- No icon (nil) falls back to the plain color square that's always
	-- existed (border on, opaque square); icon 1-8 swaps in the matching
	-- raid target texture, which has its own transparent silhouette -- the
	-- square border stays hidden for those so it doesn't show through as an
	-- ugly black box around the icon's actual (non-square) shape.
	function entry.SetIcon(newIcon)
		entry.icon = newIcon
		if newIcon and RAID_ICONS[newIcon] then
			tex:SetTexture(RAID_ICONS[newIcon])
			border:Hide()
		else
			tex:SetTexture(POINT_COLOR[1], POINT_COLOR[2], POINT_COLOR[3], POINT_COLOR[4])
			border:Show()
		end
	end
	entry.SetIcon(icon)

	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetText(entry.title ~= "" and entry.title or "(untitled note)", 1, 1, 1)
		if entry.text ~= "" then
			GameTooltip:AddLine(entry.text, 0.9, 0.9, 0.9, true)
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

	frame:SetScript("OnClick", function(self)
		if mode == "erase" then
			Draw.RemovePoint(entry)
		elseif Draw.onPointClick then
			Draw.onPointClick(entry)
		end
	end)

	pointWidgets[#pointWidgets + 1] = entry
	return entry
end

-- Public API ---------------------------------------------------------------

-- onPointClick(entry): called when a point is clicked outside erase mode.
-- Set this from UI.lua to open the note editor. entry has x,y,title,text and
-- entry.SetTitleText(title, text) to update after editing.
Draw.onPointClick = nil

function Draw.Init(canvasFrame)
	canvas = canvasFrame
	canvas:EnableMouse(true)

	canvas:SetScript("OnMouseDown", function(self, button)
		if button ~= "LeftButton" then return end
		if mode == "line" then
			local x, y = GetNormalizedCursorPos()
			x, y = ClampNorm(x), ClampNorm(y)
			painting = true
			currentStrokeId = AllocateStrokeId()
			strokeHasSegment = false
			lastX, lastY = x, y
		elseif mode == "point" then
			local x, y = GetNormalizedCursorPos()
			local entry = CreatePointWidget(ClampNorm(x), ClampNorm(y), "", "", nil)
			history[#history + 1] = { kind = "point", entry = entry }
			if Draw.onPointClick then
				Draw.onPointClick(entry)
			end
		elseif mode == "erase" then
			local x, y = GetNormalizedCursorPos()
			x, y = ClampNorm(x), ClampNorm(y)
			local strokeId = FindNearestStrokeId(x, y)
			if strokeId then
				Draw.RemoveStrokeById(strokeId)
			end
		end
	end)

	canvas:SetScript("OnUpdate", function(self)
		if mode == "line" and painting then
			local x, y = GetNormalizedCursorPos()
			x, y = ClampNorm(x), ClampNorm(y)
			local dx, dy = x - lastX, y - lastY
			if math.sqrt(dx * dx + dy * dy) >= MIN_SEGMENT_DIST then
				CreateLineWidget(lastX, lastY, x, y, currentStrokeId, currentLineColor)
				strokeHasSegment = true
				lastX, lastY = x, y
			end
		end
	end)

	canvas:SetScript("OnMouseUp", function(self, button)
		if button ~= "LeftButton" then return end
		if mode == "line" and painting then
			local x, y = GetNormalizedCursorPos()
			x, y = ClampNorm(x), ClampNorm(y)
			local dx, dy = x - lastX, y - lastY
			if math.sqrt(dx * dx + dy * dy) > 0.0005 then
				CreateLineWidget(lastX, lastY, x, y, currentStrokeId, currentLineColor)
				strokeHasSegment = true
			end
			if strokeHasSegment then
				history[#history + 1] = { kind = "stroke", strokeId = currentStrokeId }
			end
			painting = false
			currentStrokeId = nil
		end
	end)
end

function Draw.SetMode(newMode)
	mode = newMode
	painting = false
	currentStrokeId = nil
end

function Draw.GetMode()
	return mode
end

function Draw.RemovePoint(entry)
	entry.frame:Hide()
	entry.frame:SetParent(nil)
	for i, p in ipairs(pointWidgets) do
		if p == entry then table.remove(pointWidgets, i); break end
	end
	for i = #history, 1, -1 do
		if history[i].kind == "point" and history[i].entry == entry then
			table.remove(history, i)
		end
	end
end

-- Removes every segment belonging to a stroke (a freehand drag, or a single
-- imported/loaded line, which is just a one-segment stroke) and drops any
-- undo-history entry pointing at it, so a later Undo can't reference a
-- stroke that erase-mode already deleted.
function Draw.RemoveStrokeById(strokeId)
	for i = #lineWidgets, 1, -1 do
		local l = lineWidgets[i]
		if l.strokeId == strokeId then
			l.tex:Hide()
			table.remove(lineWidgets, i)
		end
	end
	for i = #history, 1, -1 do
		if history[i].kind == "stroke" and history[i].strokeId == strokeId then
			table.remove(history, i)
		end
	end
end

function Draw.Undo()
	local last = table.remove(history)
	if not last then return end
	if last.kind == "stroke" then
		Draw.RemoveStrokeById(last.strokeId)
	elseif last.kind == "point" then
		Draw.RemovePoint(last.entry)
	end
end

function Draw.Clear()
	for _, l in ipairs(lineWidgets) do l.tex:Hide() end
	for _, p in ipairs(pointWidgets) do p.frame:Hide(); p.frame:SetParent(nil) end
	lineWidgets = {}
	pointWidgets = {}
	history = {}
	painting = false
	currentStrokeId = nil
end

-- Reposition all existing widgets, e.g. after the canvas is resized.
function Draw.RelayoutAll()
	for _, l in ipairs(lineWidgets) do
		PositionLineTexture(l.tex, l.x1, l.y1, l.x2, l.y2)
	end
	for _, p in ipairs(pointWidgets) do
		PositionPointFrame(p.frame, p.x, p.y)
	end
end

-- Serialize current canvas contents into plain data tables. Lines carry
-- their color as elements 5-7 (RGB) after the 4 coords -- old saved routes
-- without those just don't have them, which LoadRouteData treats as "use
-- the default color", so this is a backward-compatible wire format change.
function Draw.GetRouteData()
	local lines, points = {}, {}
	for _, l in ipairs(lineWidgets) do
		lines[#lines + 1] = { l.x1, l.y1, l.x2, l.y2, l.color[1], l.color[2], l.color[3] }
	end
	for _, p in ipairs(pointWidgets) do
		points[#points + 1] = { x = p.x, y = p.y, title = p.title, text = p.text, icon = p.icon }
	end
	return lines, points
end

-- Load route data onto the canvas, replacing whatever is currently there.
-- Segments from saved/imported data don't carry stroke grouping, so each one
-- becomes its own single-segment stroke for erase/undo purposes. Color is
-- elements 5-7 (RGB) if present; older saved data without it just uses the
-- default color (CreateLineWidget's own fallback).
function Draw.LoadRouteData(lines, points)
	Draw.Clear()
	for _, l in ipairs(lines or {}) do
		local color = l[5] and { l[5], l[6], l[7], DEFAULT_LINE_COLOR[4] } or nil
		CreateLineWidget(l[1], l[2], l[3], l[4], AllocateStrokeId(), color)
	end
	for _, p in ipairs(points or {}) do
		CreatePointWidget(p.x, p.y, p.title, p.text, p.icon)
	end
end
