AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper
DR.MapTexture = {}

local TILE_COLS, TILE_ROWS = 4, 3
local NUM_TILES = TILE_COLS * TILE_ROWS

local function EnsureWidgets(canvasFrame)
	if canvasFrame.dr_tiles then return end

	canvasFrame.dr_tiles = {}
	for i = 1, NUM_TILES do
		local tex = canvasFrame:CreateTexture(nil, "BACKGROUND")
		local col = (i - 1) % TILE_COLS
		local row = math.floor((i - 1) / TILE_COLS)
		tex:SetPoint("TOPLEFT", canvasFrame, "TOPLEFT",
			col * (canvasFrame:GetWidth() / TILE_COLS),
			-row * (canvasFrame:GetHeight() / TILE_ROWS))
		tex:SetWidth(canvasFrame:GetWidth() / TILE_COLS)
		tex:SetHeight(canvasFrame:GetHeight() / TILE_ROWS)
		canvasFrame.dr_tiles[i] = tex
	end

	local placeholderBG = canvasFrame:CreateTexture(nil, "BACKGROUND")
	placeholderBG:SetAllPoints(canvasFrame)
	placeholderBG:SetTexture(0.10, 0.10, 0.12, 1)
	canvasFrame.dr_placeholderBG = placeholderBG

	canvasFrame.dr_gridLines = {}
	local GRID_DIVISIONS = 8
	for i = 1, GRID_DIVISIONS - 1 do
		local vLine = canvasFrame:CreateTexture(nil, "ARTWORK")
		vLine:SetTexture(1, 1, 1, 0.06)
		vLine:SetWidth(1)
		vLine:SetPoint("TOPLEFT", canvasFrame, "TOPLEFT", (i / GRID_DIVISIONS) * canvasFrame:GetWidth(), 0)
		vLine:SetPoint("BOTTOMLEFT", canvasFrame, "BOTTOMLEFT", (i / GRID_DIVISIONS) * canvasFrame:GetWidth(), 0)
		canvasFrame.dr_gridLines[#canvasFrame.dr_gridLines + 1] = vLine

		local hLine = canvasFrame:CreateTexture(nil, "ARTWORK")
		hLine:SetTexture(1, 1, 1, 0.06)
		hLine:SetHeight(1)
		hLine:SetPoint("TOPLEFT", canvasFrame, "TOPLEFT", 0, -(i / GRID_DIVISIONS) * canvasFrame:GetHeight())
		hLine:SetPoint("TOPRIGHT", canvasFrame, "TOPRIGHT", 0, -(i / GRID_DIVISIONS) * canvasFrame:GetHeight())
		canvasFrame.dr_gridLines[#canvasFrame.dr_gridLines + 1] = hLine
	end

	local msg = canvasFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	msg:SetPoint("TOP", canvasFrame, "TOP", 0, -12)
	msg:SetWidth(canvasFrame:GetWidth() - 40)
	msg:SetJustifyH("CENTER")
	canvasFrame.dr_placeholderMsg = msg
end

local function HideRealTiles(canvasFrame)
	for _, tex in ipairs(canvasFrame.dr_tiles) do
		tex:SetTexture(nil)
		tex:Hide()
	end
end

local function ShowPlaceholder(canvasFrame, message)
	HideRealTiles(canvasFrame)
	canvasFrame.dr_placeholderBG:Show()
	for _, line in ipairs(canvasFrame.dr_gridLines) do line:Show() end
	canvasFrame.dr_placeholderMsg:SetText(message)
	canvasFrame.dr_placeholderMsg:Show()
end

local function HidePlaceholder(canvasFrame)
	canvasFrame.dr_placeholderBG:Hide()
	for _, line in ipairs(canvasFrame.dr_gridLines) do line:Hide() end
	canvasFrame.dr_placeholderMsg:Hide()
end

function DR.MapTexture.ShowEmpty(canvasFrame, message)
	EnsureWidgets(canvasFrame)
	ShowPlaceholder(canvasFrame, message or "Select a dungeon or raid from the list on the left.")
end

function DR.MapTexture.Build(canvasFrame, dungeonKey, level)
	EnsureWidgets(canvasFrame)
	level = level or 0

	local known = DR.GetKnownMap(dungeonKey)
	if not known then
		ShowPlaceholder(canvasFrame,
			"No map data yet for this instance.\nWalk inside it once (with this addon loaded) to unlock the real map.")
		return false
	end

	local skipped, mapFileName, usedOutsideZone, finalDungeonLevel = DR.WithSavedMapState(function()
		SetMapByID(known.mapID)
		local dungeonLevel = level
		if DungeonUsesTerrainMap() then
			dungeonLevel = dungeonLevel - 1
		end
		if dungeonLevel > 0 then
			SetDungeonMapLevel(dungeonLevel)
		end

		local mapFileName = GetMapInfo()
		local usedOutsideZone = false

		if not mapFileName and known.outsideZoneMapID then
			SetMapByID(known.outsideZoneMapID)
			mapFileName = GetMapInfo()
			dungeonLevel = 0
			usedOutsideZone = mapFileName and true or false
		end

		return mapFileName, usedOutsideZone, dungeonLevel
	end)

	if skipped then
		ShowPlaceholder(canvasFrame,
			"Close your World Map to load this dungeon's map here (they can't be open at the same time).")
		return false
	end

	if not mapFileName then
		if known.outsideZoneMapID then
			ShowPlaceholder(canvasFrame,
				"This instance has no built-in map art, and the surrounding zone map\ncouldn't be loaded either. You can still draw routes and add notes below.")
		else
			ShowPlaceholder(canvasFrame,
				"This instance has no built-in map art in this client version.\nWalk in from the outdoor entrance once to unlock a nearby-zone backdrop.")
		end
		return false
	end

	HidePlaceholder(canvasFrame)
	local completeMapFileName = finalDungeonLevel > 0 and (mapFileName .. finalDungeonLevel .. "_") or mapFileName
	for i = 1, NUM_TILES do
		local texName = "Interface\\WorldMap\\" .. mapFileName .. "\\" .. completeMapFileName .. i
		local tex = canvasFrame.dr_tiles[i]
		tex:SetTexture(texName)
		tex:Show()
	end

	if usedOutsideZone then
		canvasFrame.dr_placeholderMsg:SetText("(showing the surrounding zone map -- no interior map exists for this instance in this client)")
		canvasFrame.dr_placeholderMsg:Show()
	else
		canvasFrame.dr_placeholderMsg:Hide()
	end

	return true
end
