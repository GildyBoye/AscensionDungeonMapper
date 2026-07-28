AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper
DR.DrawEngine = {}
local Draw = DR.DrawEngine

local LINE_THICKNESS = 3
local DEFAULT_LINE_COLOR = { 0.2, 0.55, 0.95, 0.95 }
local POINT_SIZE = 14
local POINT_COLOR = { 0.95, 0.25, 0.2, 1 }

local LINE_COLORS = {
	{ 0.2, 0.55, 0.95 },
	{ 0.9, 0.2, 0.2 },
	{ 0.25, 0.85, 0.35 },
	{ 0.95, 0.85, 0.15 },
	{ 0.65, 0.35, 0.9 },
	{ 0.95, 0.55, 0.15 },
	{ 0.95, 0.95, 0.95 },
}
Draw.LINE_COLORS = LINE_COLORS

local currentLineColor = DEFAULT_LINE_COLOR

function Draw.SetLineColor(r, g, b)
	currentLineColor = { r, g, b, DEFAULT_LINE_COLOR[4] }
end

local function ColorToIndex(color)
	for i, c in ipairs(LINE_COLORS) do
		if c[1] == color[1] and c[2] == color[2] and c[3] == color[3] then
			return i
		end
	end
	return nil
end

local COORD_SCALE = 10000

local function QuantizeCoord(v)
	return math.floor(v * COORD_SCALE + 0.5)
end

local function UnquantizeCoord(v)
	return v / COORD_SCALE
end

local function IsQuantizedCoord(v)
	return v > 1
end

local MIN_SEGMENT_DIST = 0.008

-- Caps how long a single drawn segment can be. Fast drags can move the
-- cursor a long way between two OnUpdate samples, and a single very long,
-- thin, steeply-angled rotated bar renders badly (shows up as sparse
-- horizontal-looking dashes instead of a solid line). Splitting a big jump
-- into several shorter segments along the same straight path avoids that
-- and also fills in what would otherwise be a visible gap.
local MAX_STEP_DIST = 0.01

local ERASE_TOLERANCE_PX = 6

local canvas
local mode
local history = {}

local lineWidgets = {}
local pointWidgets = {}

local nextStrokeId = 0
local function AllocateStrokeId()
	nextStrokeId = nextStrokeId + 1
	return nextStrokeId
end

local painting = false
local currentStrokeId
local strokeHasSegment
local lastX, lastY

local erasing = false

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

local function InCanvas(x, y)
	return x >= 0 and x <= 1 and y >= 0 and y <= 1
end

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

local function DrawSteppedSegment(x1, y1, x2, y2, strokeId, color)
	local dx, dy = x2 - x1, y2 - y1
	local dist = math.sqrt(dx * dx + dy * dy)
	local steps = math.max(1, math.ceil(dist / MAX_STEP_DIST))
	local px, py = x1, y1
	for i = 1, steps do
		local nx, ny = x1 + dx * (i / steps), y1 + dy * (i / steps)
		CreateLineWidget(px, py, nx, ny, strokeId, color)
		px, py = nx, ny
	end
end

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

-- Removes exactly one segment (by index), not the whole stroke it came from
-- -- classic eraser behavior, removes only what you actually drag over.
-- Returns the removed segment's data so the caller can record it for undo.
local function RemoveLineSegmentAt(index)
	local l = lineWidgets[index]
	l.tex:Hide()
	table.remove(lineWidgets, index)
	return { x1 = l.x1, y1 = l.y1, x2 = l.x2, y2 = l.y2, color = l.color }
end

local POINT_ERASE_RADIUS_PX = 14

-- Set for the duration of one erase gesture (mouse-down to mouse-up) so
-- EraseNear can accumulate what it removed; nil the rest of the time.
local eraseSessionLines
local eraseSessionPoints

-- Erases every line segment and every point within tolerance of (x, y),
-- normalized canvas coordinates. Called continuously while dragging in
-- erase mode, so a drag sweeps out an eraser path rather than needing one
-- precise click per item. Whatever it removes gets recorded into the
-- current erase session so the whole gesture can be undone as one action.
local function EraseNear(x, y)
	for i = #lineWidgets, 1, -1 do
		local l = lineWidgets[i]
		if DistPointToSegmentPx(x, y, l.x1, l.y1, l.x2, l.y2) <= ERASE_TOLERANCE_PX then
			local removed = RemoveLineSegmentAt(i)
			if eraseSessionLines then
				eraseSessionLines[#eraseSessionLines + 1] = removed
			end
		end
	end
	local w, h = canvas:GetWidth(), canvas:GetHeight()
	for i = #pointWidgets, 1, -1 do
		local p = pointWidgets[i]
		local dx, dy = (x - p.x) * w, (y - p.y) * h
		if math.sqrt(dx * dx + dy * dy) <= POINT_ERASE_RADIUS_PX then
			if eraseSessionPoints then
				eraseSessionPoints[#eraseSessionPoints + 1] = { x = p.x, y = p.y, title = p.title, text = p.text, icon = p.icon }
			end
			Draw.RemovePoint(p)
		end
	end
end

-- Every selectable marker icon, in a fixed order so existing saved/shared
-- points (which store just an index into this list) keep pointing at the
-- same icon after this list grows. Only append, never reorder/remove.
local POINT_ICONS = {}
for i = 1, 8 do
	POINT_ICONS[#POINT_ICONS + 1] = {
		texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i,
		name = "Raid Icon " .. i,
	}
end

-- Coordinates match Blizzard's own FrameXML usage of this texture
-- (LFGFrame.lua), a 64x64 sheet -- not a uniform grid, so these can't be
-- derived, only copied from the source.
local ROLE_ICON_TEXTURE = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
local ROLES = {
	{ name = "Tank", texCoord = { 0 / 64, 19 / 64, 22 / 64, 41 / 64 } },
	{ name = "Healer", texCoord = { 20 / 64, 39 / 64, 1 / 64, 20 / 64 } },
	{ name = "DPS", texCoord = { 20 / 64, 39 / 64, 22 / 64, 41 / 64 } },
}
for _, role in ipairs(ROLES) do
	POINT_ICONS[#POINT_ICONS + 1] = { texture = ROLE_ICON_TEXTURE, texCoord = role.texCoord, name = role.name }
end

local COLOR_NAMES = { "Blue", "Red", "Green", "Yellow", "Purple", "Orange", "White" }
for i, c in ipairs(LINE_COLORS) do
	POINT_ICONS[#POINT_ICONS + 1] = { color = c, name = COLOR_NAMES[i] .. " Marker" }
end

Draw.POINT_ICONS = POINT_ICONS

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

	function entry.SetIcon(newIcon)
		entry.icon = newIcon
		local def = newIcon and POINT_ICONS[newIcon]
		if not def then
			tex:SetTexture(POINT_COLOR[1], POINT_COLOR[2], POINT_COLOR[3], POINT_COLOR[4])
			tex:SetTexCoord(0, 1, 0, 1)
			border:Show()
		elseif def.color then
			tex:SetTexture(def.color[1], def.color[2], def.color[3], 1)
			tex:SetTexCoord(0, 1, 0, 1)
			border:Show()
		else
			tex:SetTexture(def.texture)
			local tc = def.texCoord
			if tc then
				tex:SetTexCoord(tc[1], tc[2], tc[3], tc[4])
			else
				tex:SetTexCoord(0, 1, 0, 1)
			end
			border:Hide()
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
			-- A direct click on the point's own button bypasses the canvas's
			-- drag-erase session entirely, so this goes through DeletePoint
			-- to keep Undo consistent regardless of which path removed it.
			Draw.DeletePoint(entry)
		elseif Draw.onPointClick then
			Draw.onPointClick(entry)
		end
	end)

	pointWidgets[#pointWidgets + 1] = entry
	return entry
end

Draw.onPointClick = nil

-- Fired after any action that changes what a saved route would contain (a
-- completed stroke, a placed point, an erase, an undo) -- used by the UI to
-- drive auto-save. Called via the Draw table field (not a local) so
-- earlier-defined closures in this file can still reach it. Deliberately
-- NOT fired by Draw.Clear -- see the comment on that function.
Draw.onChange = nil

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
			if Draw.onChange then Draw.onChange() end
			if Draw.onPointClick then
				Draw.onPointClick(entry)
			end
		elseif mode == "erase" then
			erasing = true
			eraseSessionLines = {}
			eraseSessionPoints = {}
			local x, y = GetNormalizedCursorPos()
			EraseNear(ClampNorm(x), ClampNorm(y))
		end
	end)

	canvas:SetScript("OnUpdate", function(self)
		if mode == "line" and painting then
			local x, y = GetNormalizedCursorPos()
			-- Ignore samples taken while the cursor has drifted off the
			-- canvas (easy to do on a fast drag, especially vertically since
			-- the canvas is shorter than it is wide) instead of clamping to
			-- the edge -- clamping was smearing a segment along whichever
			-- border got overshot.
			if InCanvas(x, y) then
				local dx, dy = x - lastX, y - lastY
				if math.sqrt(dx * dx + dy * dy) >= MIN_SEGMENT_DIST then
					DrawSteppedSegment(lastX, lastY, x, y, currentStrokeId, currentLineColor)
					strokeHasSegment = true
					lastX, lastY = x, y
				end
			end
		elseif mode == "erase" and erasing then
			local x, y = GetNormalizedCursorPos()
			EraseNear(ClampNorm(x), ClampNorm(y))
		end
	end)

	canvas:SetScript("OnMouseUp", function(self, button)
		if button ~= "LeftButton" then return end
		if mode == "line" and painting then
			local x, y = GetNormalizedCursorPos()
			if InCanvas(x, y) then
				local dx, dy = x - lastX, y - lastY
				if math.sqrt(dx * dx + dy * dy) > 0.0005 then
					DrawSteppedSegment(lastX, lastY, x, y, currentStrokeId, currentLineColor)
					strokeHasSegment = true
				end
			end
			if strokeHasSegment then
				history[#history + 1] = { kind = "stroke", strokeId = currentStrokeId }
				if Draw.onChange then Draw.onChange() end
			end
			painting = false
			currentStrokeId = nil
		elseif mode == "erase" then
			erasing = false
			if eraseSessionLines and (#eraseSessionLines > 0 or #eraseSessionPoints > 0) then
				history[#history + 1] = { kind = "erase", lines = eraseSessionLines, points = eraseSessionPoints }
				if Draw.onChange then Draw.onChange() end
			end
			eraseSessionLines = nil
			eraseSessionPoints = nil
		end
	end)
end

function Draw.SetMode(newMode)
	mode = newMode
	painting = false
	currentStrokeId = nil
	erasing = false
	eraseSessionLines = nil
	eraseSessionPoints = nil
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

-- Removes a point WITH an undo-able history entry and an onChange
-- notification -- the one true way to delete a single point, shared by the
-- erase-mode direct click and the point editor's Delete Marker button, so
-- both behave identically (a plain Draw.RemovePoint call bypasses undo).
function Draw.DeletePoint(entry)
	history[#history + 1] = { kind = "erase", lines = {}, points = {
		{ x = entry.x, y = entry.y, title = entry.title, text = entry.text, icon = entry.icon },
	} }
	Draw.RemovePoint(entry)
	if Draw.onChange then Draw.onChange() end
end

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
	elseif last.kind == "erase" then
		-- Restores exactly what one erase gesture removed. Restored items
		-- get fresh stroke IDs -- they're independently erasable again,
		-- same as anything freshly drawn.
		for _, l in ipairs(last.lines) do
			CreateLineWidget(l.x1, l.y1, l.x2, l.y2, AllocateStrokeId(), l.color)
		end
		for _, p in ipairs(last.points) do
			CreatePointWidget(p.x, p.y, p.title, p.text, p.icon)
		end
	end
	if Draw.onChange then Draw.onChange() end
end

-- Deliberately does NOT fire onChange -- it's also used to blank the canvas
-- before naming a brand new route (see the "New Route" button), and firing
-- auto-save there would silently overwrite the previously loaded route with
-- an empty one before the new name is even picked. Callers that clear an
-- already-named route in place (the Clear toolbar button) trigger auto-save
-- themselves after calling this.
function Draw.Clear()
	for _, l in ipairs(lineWidgets) do l.tex:Hide() end
	for _, p in ipairs(pointWidgets) do p.frame:Hide(); p.frame:SetParent(nil) end
	lineWidgets = {}
	pointWidgets = {}
	history = {}
	painting = false
	currentStrokeId = nil
	erasing = false
	eraseSessionLines = nil
	eraseSessionPoints = nil
end

function Draw.RelayoutAll()
	for _, l in ipairs(lineWidgets) do
		PositionLineTexture(l.tex, l.x1, l.y1, l.x2, l.y2)
	end
	for _, p in ipairs(pointWidgets) do
		PositionPointFrame(p.frame, p.x, p.y)
	end
end

function Draw.GetRouteData()
	local lines, points = {}, {}
	for _, l in ipairs(lineWidgets) do
		local entry = {
			QuantizeCoord(l.x1), QuantizeCoord(l.y1),
			QuantizeCoord(l.x2), QuantizeCoord(l.y2),
		}
		local colorIndex = ColorToIndex(l.color)
		if colorIndex then
			entry[5] = colorIndex
		else
			entry[5], entry[6], entry[7] = l.color[1], l.color[2], l.color[3]
		end
		lines[#lines + 1] = entry
	end
	for _, p in ipairs(pointWidgets) do
		points[#points + 1] = {
			x = QuantizeCoord(p.x), y = QuantizeCoord(p.y),
			title = p.title, text = p.text, icon = p.icon,
		}
	end
	return lines, points
end

-- Pure decode helpers -- no canvas/widget side effects, safe to call from
-- anywhere (e.g. a static preview renderer) that just wants to know what a
-- stored line/point actually means, across every format generation this
-- addon has ever written.
function Draw.NormalizeLineData(l)
	local x1, y1, x2, y2 = l[1], l[2], l[3], l[4]
	if IsQuantizedCoord(x1) or IsQuantizedCoord(y1) or IsQuantizedCoord(x2) or IsQuantizedCoord(y2) then
		x1, y1, x2, y2 = UnquantizeCoord(x1), UnquantizeCoord(y1), UnquantizeCoord(x2), UnquantizeCoord(y2)
	end
	local color = DEFAULT_LINE_COLOR
	if l[6] and l[7] then
		color = { l[5], l[6], l[7], DEFAULT_LINE_COLOR[4] }
	elseif l[5] and LINE_COLORS[l[5]] then
		local c = LINE_COLORS[l[5]]
		color = { c[1], c[2], c[3], DEFAULT_LINE_COLOR[4] }
	end
	return x1, y1, x2, y2, color
end

function Draw.NormalizePointData(p)
	local x, y = p.x, p.y
	if IsQuantizedCoord(x) or IsQuantizedCoord(y) then
		x, y = UnquantizeCoord(x), UnquantizeCoord(y)
	end
	return x, y
end

function Draw.LoadRouteData(lines, points)
	Draw.Clear()
	for _, l in ipairs(lines or {}) do
		local x1, y1, x2, y2, color = Draw.NormalizeLineData(l)
		CreateLineWidget(x1, y1, x2, y2, AllocateStrokeId(), color)
	end
	for _, p in ipairs(points or {}) do
		local x, y = Draw.NormalizePointData(p)
		CreatePointWidget(x, y, p.title, p.text, p.icon)
	end
end
