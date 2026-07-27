-- AscensionDungeonMapper UI
-- Main window: era toggle, dungeon list, drawing canvas, toolbar, and the
-- small popups for naming/importing/exporting routes and editing point notes.

AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper
DR.UI = {}

local CANVAS_W, CANVAS_H = 640, 420

local mainFrame
local canvas
local dungeonListContent
local dungeonButtons = {}
local dungeonHeaders = {} -- "Dungeons" / "Raids" section labels above dungeonButtons
local collapsedGroups = {} -- [era.."_"..kind] = true, session-only (not saved)
local modeButtons = {}

local currentEra = "Classic"
local currentDungeonKey = nil
local currentLevel = 0
local currentRouteName = nil

local headerDungeonText, headerRouteText, levelText, levelPrev, levelNext
local pointEditorFrame

local MAX_ROUTES_PER_DUNGEON = 5
local routeBoxSlots = {}
local RefreshRouteBox -- forward-declared: SelectDungeon (below) needs to call it

-- Small widget helpers -------------------------------------------------

local function CreateActionButton(parent, text, width)
	local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	btn:SetWidth(width or 90)
	btn:SetHeight(22)
	btn:SetText(text)
	return btn
end

-- Every "this is currently selected" indicator in the addon (mode buttons,
-- the dungeon list, route slots, marker icons, draw colors) uses this same
-- gold border rather than each having its own ad-hoc highlight style --
-- it's the same border art Blizzard uses to mark the active stance/
-- shapeshift button. Hidden by default; caller shows/hides it.
local function CreateSelectionBorder(parent, padding)
	padding = padding or 3
	local border = parent:CreateTexture(nil, "OVERLAY")
	border:SetPoint("TOPLEFT", parent, "TOPLEFT", -padding, padding)
	border:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", padding, -padding)
	border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	border:SetBlendMode("ADD")
	border:Hide()
	return border
end

-- 3.3.5 has no "BasicFrameTemplateWithInset" (that's a much later retail
-- template) so dialog-style windows are built by hand here, using the same
-- backdrop art and close button Blizzard's own StaticPopup frames use.
local function CreateBorderedFrame(name, parent, width, height, title)
	local f = CreateFrame("Frame", name, parent)
	f:SetWidth(width)
	f:SetHeight(height)
	f:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	})
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetFrameStrata("DIALOG")

	local titleFS = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	titleFS:SetPoint("TOP", f, "TOP", 0, -14)
	titleFS:SetText(title or "")
	f.titleText = titleFS

	local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
	closeBtn:SetScript("OnClick", function() f:Hide() end)

	return f
end

local function CreateListButton(parent, width)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetWidth(width)
	btn:SetHeight(20)
	btn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
	local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fs:SetPoint("LEFT", btn, "LEFT", 4, 0)
	fs:SetJustifyH("LEFT")
	fs:SetWidth(width - 8)
	btn.text = fs
	local dot = btn:CreateTexture(nil, "OVERLAY")
	dot:SetWidth(6)
	dot:SetHeight(6)
	dot:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
	btn.dot = dot
	-- Wide/short list rows don't suit the square action-button border used
	-- elsewhere -- it's built for roughly-square buttons and stretches badly
	-- at this aspect ratio. Use Blizzard's own selected-list-row texture
	-- instead (the same one the quest log uses for its selected entry).
	local selectedBar = btn:CreateTexture(nil, "OVERLAY")
	selectedBar:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, 2)
	selectedBar:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, -2)
	selectedBar:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	selectedBar:SetBlendMode("ADD")
	selectedBar:Hide()
	btn.selectedBorder = selectedBar
	return btn
end

-- modeButtons is keyed by mode string ("line"/"point"/"erase"). mode == nil
-- ("no tool active") has no button of its own -- clicking whichever tool is
-- currently active toggles it back off.
local function SetModeButtonHighlight(activeMode)
	for m, btn in pairs(modeButtons) do
		if m == activeMode then
			btn.selectedBorder:Show()
		else
			btn.selectedBorder:Hide()
		end
	end
end

-- Dungeon list -----------------------------------------------------------

local function SelectDungeon(key)
	currentDungeonKey = key
	local info = DR.DungeonByKey[key]
	local mapKey = info.parentKey or key
	local known = DR.GetKnownMap(mapKey)
	currentLevel = info.level or ((known and known.numLevels and known.numLevels > 0) and 1 or 0)
	currentRouteName = nil

	headerDungeonText:SetText(info.name)
	headerRouteText:SetText("(no route loaded)")

	DR.DrawEngine.Clear()
	DR.MapTexture.Build(canvas, mapKey, currentLevel)
	DR.UI.UpdateLevelDisplay()

	-- Auto-load the most recently updated route, if any.
	local routes = DR.GetRoutesForDungeon(key)
	local bestName, bestTime = nil, -1
	for name, data in pairs(routes) do
		if (data.updated or 0) > bestTime then
			bestName, bestTime = name, data.updated or 0
		end
	end
	if bestName then
		DR.UI.LoadRoute(bestName)
	end

	for _, btn in ipairs(dungeonButtons) do
		if btn.dungeonKey == key then
			btn.selectedBorder:Show()
		else
			btn.selectedBorder:Hide()
		end
	end

	RefreshRouteBox()
end

local HEADER_ROW_HEIGHT = 16
local BUTTON_ROW_HEIGHT = 20

local RefreshDungeonList -- forward-declared: header OnClick below needs to call it

local function GetOrCreateHeader(index)
	local header = dungeonHeaders[index]
	if not header then
		header = CreateFrame("Button", nil, dungeonListContent)
		header:SetWidth(210)
		header:SetHeight(HEADER_ROW_HEIGHT)
		header:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
		local fs = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		fs:SetPoint("LEFT", header, "LEFT", 2, 0)
		fs:SetTextColor(0.5, 0.75, 1, 1)
		header.text = fs
		header:SetScript("OnClick", function(self)
			collapsedGroups[self.groupKey] = not collapsedGroups[self.groupKey]
			RefreshDungeonList()
		end)
		dungeonHeaders[index] = header
	end
	return header
end

-- DR.Dungeons entries are already ordered dungeons-then-raids per era (see
-- MapData.lua), so a "Dungeons" / "Raids" header just needs to be inserted
-- wherever entry.kind changes -- no re-sorting required. Collapsed groups
-- (click a header to toggle) skip laying out their buttons entirely; the
-- collapse state is session-only, not saved.
function RefreshDungeonList()
	local list = DR.Dungeons[currentEra]
	local yOffset = 0
	local btnCount, headerCount = 0, 0
	local lastKind = nil
	local groupCollapsed = false

	for _, entry in ipairs(list) do
		if not entry.hidden then
			if entry.kind ~= lastKind then
				headerCount = headerCount + 1
				local groupKey = currentEra .. "_" .. entry.kind
				groupCollapsed = collapsedGroups[groupKey] or false
				local header = GetOrCreateHeader(headerCount)
				header.groupKey = groupKey
				header:ClearAllPoints()
				header:SetPoint("TOPLEFT", dungeonListContent, "TOPLEFT", 0, -yOffset)
				header.text:SetText((groupCollapsed and "[+] " or "[-] ") .. (entry.kind == "raid" and "Raids" or "Dungeons"))
				header:Show()
				yOffset = yOffset + HEADER_ROW_HEIGHT
				lastKind = entry.kind
			end

			if not groupCollapsed then
				btnCount = btnCount + 1
				local btn = dungeonButtons[btnCount]
				if not btn then
					btn = CreateListButton(dungeonListContent, 210)
					dungeonButtons[btnCount] = btn
				end
				btn:ClearAllPoints()
				btn:SetPoint("TOPLEFT", dungeonListContent, "TOPLEFT", 0, -yOffset)
				btn:Show()
				btn.dungeonKey = entry.key
				-- Embedded color code keeps the level range muted regardless
				-- of selection state, which is shown via selectedBorder
				-- (gold border) rather than changing the text color.
				btn.text:SetText(entry.levelRange and (entry.name .. " |cff888888(" .. entry.levelRange .. ")|r") or entry.name)
				btn.text:SetTextColor(1, 1, 1)
				if entry.key == currentDungeonKey then
					btn.selectedBorder:Show()
				else
					btn.selectedBorder:Hide()
				end
				if DR.GetKnownMap(entry.parentKey or entry.key) then
					btn.dot:SetTexture(0.3, 0.9, 0.3, 1)
				else
					btn.dot:SetTexture(0.5, 0.5, 0.5, 0.6)
				end
				btn:SetScript("OnClick", function() SelectDungeon(entry.key) end)
				yOffset = yOffset + BUTTON_ROW_HEIGHT
			end
		end
	end

	for i = btnCount + 1, #dungeonButtons do
		dungeonButtons[i]:Hide()
	end
	for i = headerCount + 1, #dungeonHeaders do
		dungeonHeaders[i]:Hide()
	end
	dungeonListContent:SetHeight(math.max(yOffset, 1))
end

local function SetEra(era)
	currentEra = era
	currentDungeonKey = nil
	currentRouteName = nil
	headerDungeonText:SetText("Select a dungeon or raid on the left")
	headerRouteText:SetText("")
	DR.DrawEngine.Clear()
	DR.MapTexture.ShowEmpty(canvas)
	RefreshDungeonList()
	RefreshRouteBox()
end

-- Level controls -----------------------------------------------------------

-- A wing entry's level range is [info.level, info.maxLevel or info.level].
-- Single-floor wings (Scarlet Monastery's, Dire Maul's North) have no
-- maxLevel, so that range is a single number and the control has nothing to
-- do -- switching levels out from under those would silently start saving
-- another wing's routes under this wing's key. Multi-floor wings (Dire
-- Maul's West/East) get a working control clamped to their own range so you
-- can still move between their internal floors.
local function WingLevelRange(info)
	if not info or not info.level then return nil, nil end
	return info.level, info.maxLevel or info.level
end

function DR.UI.UpdateLevelDisplay()
	local info = currentDungeonKey and DR.DungeonByKey[currentDungeonKey]
	local known = info and DR.GetKnownMap(info.parentKey or currentDungeonKey)
	local minLevel, maxLevel = WingLevelRange(info)
	local showControl
	if minLevel then
		showControl = maxLevel > minLevel
	else
		showControl = info and known and known.numLevels and known.numLevels > 1
	end
	if showControl then
		levelText:SetText(("Level %d / %d"):format(currentLevel, known.numLevels))
		levelText:Show()
		levelPrev:Show()
		levelNext:Show()
	else
		levelText:Hide()
		levelPrev:Hide()
		levelNext:Hide()
	end
end

local function ChangeLevel(delta)
	if not currentDungeonKey then return end
	local info = DR.DungeonByKey[currentDungeonKey]
	local mapKey = info.parentKey or currentDungeonKey
	local known = DR.GetKnownMap(mapKey)
	if not known or not known.numLevels or known.numLevels <= 1 then return end
	local minLevel, maxLevel = WingLevelRange(info)
	minLevel, maxLevel = minLevel or 1, maxLevel or known.numLevels
	local newLevel = currentLevel + delta
	if newLevel < minLevel or newLevel > maxLevel then return end
	currentLevel = newLevel
	DR.MapTexture.Build(canvas, mapKey, currentLevel)
	DR.UI.UpdateLevelDisplay()
end

-- Route management -----------------------------------------------------

function DR.UI.LoadRoute(name)
	if not currentDungeonKey then return end
	local routes = DR.GetRoutesForDungeon(currentDungeonKey)
	local data = routes[name]
	if not data then return end
	local info = DR.DungeonByKey[currentDungeonKey]
	currentRouteName = name
	-- Prefer the level the route was actually drawn on over the wing's
	-- default start level -- matters for wings that span multiple floors
	-- (e.g. Dire Maul's West/East), where a saved route might be on any of
	-- them, not just the first.
	currentLevel = data.level or info.level or 0
	DR.MapTexture.Build(canvas, info.parentKey or currentDungeonKey, currentLevel)
	DR.DrawEngine.LoadRouteData(data.lines, data.points)
	DR.UI.UpdateLevelDisplay()
	headerRouteText:SetText("Route: " .. name .. " (by " .. (data.author or "?") .. ")")
	RefreshRouteBox()
end

local function SaveCurrentRoute()
	if not currentDungeonKey then
		DR.Print("Select a dungeon first.")
		return
	end
	if not currentRouteName then
		StaticPopup_Show("ASCENSIONDUNGEONMAPPER_NEW_ROUTE")
		return
	end
	local lines, points = DR.DrawEngine.GetRouteData()
	local existing = DR.GetRoutesForDungeon(currentDungeonKey)[currentRouteName]
	local playerName = UnitName("player") or "Unknown"
	local realmName = GetRealmName() or ""
	local routeData = {
		author = playerName .. "-" .. realmName,
		level = currentLevel,
		created = (existing and existing.created) or time(),
		updated = time(),
		lines = lines,
		points = points,
	}
	DR.SaveRoute(currentDungeonKey, currentRouteName, routeData)
	headerRouteText:SetText("Route: " .. currentRouteName .. " (saved)")
	DR.Print("Saved route '" .. currentRouteName .. "'.")
	RefreshRouteBox()
end

-- Each dungeon (or wing, for split entries like Scarlet Monastery) gets up
-- to MAX_ROUTES_PER_DUNGEON saved routes, shown as fixed slots in the route
-- box -- renaming/overwriting an existing route doesn't count against the cap.
--
-- This is shared by two different callers with two different intents: the
-- "New Route" button (wants a genuinely blank canvas under the new name --
-- that button clears the canvas itself, before this ever runs) and Save's
-- fallback when no route is named yet (the user has very likely already
-- drawn something -- e.g. picked a dungeon and started drawing immediately
-- without naming a route first -- and just wants it saved under a name, not
-- wiped). So this function itself must never clear the canvas.
function DR.UI.CreateNewRoute(name)
	name = DR.Trim(name)
	if name == "" then
		DR.Print("Route name can't be empty.")
		return
	end
	if not currentDungeonKey then
		DR.Print("Select a dungeon first.")
		return
	end
	local routes = DR.GetRoutesForDungeon(currentDungeonKey)
	if not routes[name] then
		local count = 0
		for _ in pairs(routes) do count = count + 1 end
		if count >= MAX_ROUTES_PER_DUNGEON then
			DR.Print(("This dungeon already has %d saved routes (the max). Delete one first."):format(MAX_ROUTES_PER_DUNGEON))
			return
		end
	end
	currentRouteName = name
	SaveCurrentRoute()
end

local function DeleteCurrentRoute()
	if not currentDungeonKey or not currentRouteName then return end
	DR.DeleteRoute(currentDungeonKey, currentRouteName)
	DR.Print("Deleted route '" .. currentRouteName .. "'.")
	currentRouteName = nil
	headerRouteText:SetText("(no route loaded)")
	DR.DrawEngine.Clear()
	RefreshRouteBox()
end

-- Route box: persistent MAX_ROUTES_PER_DUNGEON-slot list for the selected
-- dungeon, built once in BuildMainFrame (routeBoxSlots) and refreshed
-- whenever the selection or the route list changes.
function RefreshRouteBox()
	if #routeBoxSlots == 0 then return end -- not built yet
	local routes = currentDungeonKey and DR.GetRoutesForDungeon(currentDungeonKey) or {}
	local names = {}
	for name in pairs(routes) do names[#names + 1] = name end
	table.sort(names)

	for i = 1, MAX_ROUTES_PER_DUNGEON do
		local slot = routeBoxSlots[i]
		local name = names[i]
		if name then
			slot.text:SetText(name)
			slot.text:SetTextColor(1, 1, 1)
			if name == currentRouteName then slot.selectedBorder:Show() else slot.selectedBorder:Hide() end
			slot:SetScript("OnClick", function() DR.UI.LoadRoute(name) end)
			slot:EnableMouse(true)
		else
			slot.text:SetText("|cff555555(empty)|r")
			slot.selectedBorder:Hide()
			slot:SetScript("OnClick", nil)
			slot:EnableMouse(false)
		end
	end
end

-- Point editor -------------------------------------------------------------

local editingEntry

local ICON_PICKER_SIZE = 24

-- One button in the point-editor icon row. iconValue is nil for "no icon"
-- (falls back to the plain color square) or 1-8 for a raid target marker.
local function MakeIconButton(iconRow, index, iconValue, texturePath)
	local btn = CreateFrame("Button", nil, iconRow)
	btn:SetWidth(ICON_PICKER_SIZE)
	btn:SetHeight(ICON_PICKER_SIZE)
	btn:SetPoint("LEFT", iconRow, "LEFT", (index - 1) * (ICON_PICKER_SIZE + 4), 0)

	local tex = btn:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints(btn)
	if texturePath then
		tex:SetTexture(texturePath)
	else
		tex:SetTexture(0.4, 0.4, 0.4, 1)
	end

	btn.selectedBorder = CreateSelectionBorder(btn, 2)
	btn.iconValue = iconValue

	btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

	btn:SetScript("OnClick", function() iconRow:SetSelected(iconValue) end)
	btn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(iconValue and ("Icon " .. iconValue) or "No icon", 1, 1, 1)
		GameTooltip:Show()
	end)
	btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

	iconRow.buttons[#iconRow.buttons + 1] = btn
	return btn
end

local function BuildIconPicker(parent)
	local iconRow = CreateFrame("Frame", nil, parent)
	local count = #DR.DrawEngine.RAID_ICONS + 1
	iconRow:SetWidth(count * (ICON_PICKER_SIZE + 4))
	iconRow:SetHeight(ICON_PICKER_SIZE)
	iconRow.buttons = {}
	iconRow.selected = nil

	function iconRow:SetSelected(icon)
		self.selected = icon
		for _, b in ipairs(self.buttons) do
			if b.iconValue == icon then
				b.selectedBorder:Show()
			else
				b.selectedBorder:Hide()
			end
		end
	end

	MakeIconButton(iconRow, 1, nil, nil)
	for i, texturePath in ipairs(DR.DrawEngine.RAID_ICONS) do
		MakeIconButton(iconRow, i + 1, i, texturePath)
	end

	return iconRow
end

local function BuildPointEditor()
	local f = CreateBorderedFrame("AscensionDungeonMapperPointEditor", UIParent, 320, 320, "Marker Note")
	f:SetPoint("CENTER")

	local titleLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	titleLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -34)
	titleLabel:SetText("Title")

	local titleBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
	titleBox:SetWidth(280)
	titleBox:SetHeight(20)
	titleBox:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 4, -6)
	titleBox:SetAutoFocus(false)
	f.titleBox = titleBox

	local iconLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	iconLabel:SetPoint("TOPLEFT", titleBox, "BOTTOMLEFT", -4, -12)
	iconLabel:SetText("Icon")

	local iconRow = BuildIconPicker(f)
	iconRow:SetPoint("TOPLEFT", iconLabel, "BOTTOMLEFT", 4, -6)
	f.iconRow = iconRow

	local descLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	descLabel:SetPoint("TOPLEFT", iconRow, "BOTTOMLEFT", -4, -12)
	descLabel:SetText("Description")

	local scrollFrame = CreateFrame("ScrollFrame", "AscensionDungeonMapperPointEditorScroll", f, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", descLabel, "BOTTOMLEFT", 4, -6)
	scrollFrame:SetWidth(260)
	scrollFrame:SetHeight(110)

	local descBox = CreateFrame("EditBox", nil, scrollFrame)
	descBox:SetMultiLine(true)
	descBox:SetWidth(255)
	descBox:SetHeight(300)
	descBox:SetFontObject(ChatFontNormal)
	descBox:SetAutoFocus(false)
	descBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	scrollFrame:SetScrollChild(descBox)
	f.descBox = descBox

	local saveBtn = CreateActionButton(f, "Save", 80)
	saveBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 14, 14)
	saveBtn:SetScript("OnClick", function()
		if editingEntry then
			editingEntry.title = f.titleBox:GetText()
			editingEntry.text = f.descBox:GetText()
			editingEntry.SetIcon(f.iconRow.selected)
		end
		f:Hide()
	end)

	local deleteBtn = CreateActionButton(f, "Delete Marker", 100)
	deleteBtn:SetPoint("LEFT", saveBtn, "RIGHT", 8, 0)
	deleteBtn:SetScript("OnClick", function()
		if editingEntry then
			DR.DrawEngine.RemovePoint(editingEntry)
		end
		f:Hide()
	end)

	local cancelBtn = CreateActionButton(f, "Cancel", 80)
	cancelBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 14)
	cancelBtn:SetScript("OnClick", function() f:Hide() end)

	return f
end

local function OpenPointEditor(entry)
	if not pointEditorFrame then
		pointEditorFrame = BuildPointEditor()
	end
	editingEntry = entry
	pointEditorFrame.titleBox:SetText(entry.title or "")
	pointEditorFrame.descBox:SetText(entry.text or "")
	pointEditorFrame.iconRow:SetSelected(entry.icon)
	pointEditorFrame:Show()
	pointEditorFrame.titleBox:SetFocus()
end

-- Export / Import ------------------------------------------------------

StaticPopupDialogs["ASCENSIONDUNGEONMAPPER_NEW_ROUTE"] = {
	text = "Name this route:",
	button1 = "Create",
	button2 = CANCEL,
	hasEditBox = true,
	maxLetters = 64,
	OnAccept = function(self)
		DR.UI.CreateNewRoute(self.editBox:GetText())
	end,
	EditBoxOnEnterPressed = function(self)
		DR.UI.CreateNewRoute(self:GetText())
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- 3.3.5 has no API to open a browser, so "linking" to GitHub/Discord means
-- the same thing Export does: show the URL in a copyable edit box.
local GITHUB_URL = "https://github.com/GildyBoye/AscensionDungeonMapper"
local DISCORD_URL = "https://discord.com/invite/mQjgHCW"

StaticPopupDialogs["ASCENSIONDUNGEONMAPPER_GITHUB_LINK"] = {
	text = "AscensionDungeonMapper on GitHub\nCtrl+A then Ctrl+C to copy:",
	button1 = CLOSE,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function(self)
		self.editBox:SetText(GITHUB_URL)
		self.editBox:HighlightText()
		self.editBox:SetFocus()
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

StaticPopupDialogs["ASCENSIONDUNGEONMAPPER_DISCORD_LINK"] = {
	text = "Join the Discord\nCtrl+A then Ctrl+C to copy:",
	button1 = CLOSE,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function(self)
		self.editBox:SetText(DISCORD_URL)
		self.editBox:HighlightText()
		self.editBox:SetFocus()
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

StaticPopupDialogs["ASCENSIONDUNGEONMAPPER_CONFIRM_CLEAR"] = {
	text = "Clear the entire map? This removes every line and point and can't be undone.",
	button1 = "Clear",
	button2 = CANCEL,
	OnAccept = function() DR.DrawEngine.Clear() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

function DR.UI.HandleImport(text)
	local ok, dungeonKey, routeName, routeData, err = DR.ShareExport.Import(text)
	if not ok then
		DR.Print("Import failed: " .. tostring(err))
		return
	end
	local existingRoutes = DR.GetRoutesForDungeon(dungeonKey)
	if existingRoutes[routeName] then
		routeName = routeName .. " (imported)"
	end
	if not existingRoutes[routeName] then
		local count = 0
		for _ in pairs(existingRoutes) do count = count + 1 end
		if count >= MAX_ROUTES_PER_DUNGEON then
			DR.Print(("Import failed: that dungeon already has %d saved routes (the max). Delete one first."):format(MAX_ROUTES_PER_DUNGEON))
			return
		end
	end
	DR.SaveRoute(dungeonKey, routeName, routeData)

	local info = DR.DungeonByKey[dungeonKey]
	SetEra(info.era)
	SelectDungeon(dungeonKey)
	DR.UI.LoadRoute(routeName)
	DR.Print("Imported route '" .. routeName .. "' for " .. info.name .. ".")
end

-- Export/Import text dialogs. StaticPopup's built-in edit box is single-line
-- and only 350px wide -- fine for a short URL, but a compressed route string
-- can run to hundreds or thousands of characters, and having it all scroll
-- sideways inside a tiny box makes it hard to trust a Ctrl+A actually
-- grabbed everything. These give a real multi-line scrollable box instead.
local TEXT_DIALOG_W, TEXT_DIALOG_H = 520, 360

local function BuildTextDialog(name, title)
	local f = CreateBorderedFrame(name, UIParent, TEXT_DIALOG_W, TEXT_DIALOG_H, title)
	f:SetPoint("CENTER")
	f:SetFrameStrata("DIALOG")
	f:Hide()

	local hint = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	hint:SetPoint("TOP", f, "TOP", 0, -32)
	f.hint = hint

	local scrollFrame = CreateFrame("ScrollFrame", name .. "Scroll", f, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -54)
	scrollFrame:SetWidth(TEXT_DIALOG_W - 50)
	scrollFrame:SetHeight(TEXT_DIALOG_H - 100)

	local editBox = CreateFrame("EditBox", nil, scrollFrame)
	editBox:SetMultiLine(true)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(TEXT_DIALOG_W - 50)
	editBox:SetHeight(TEXT_DIALOG_H - 100)
	editBox:SetAutoFocus(false)
	editBox:SetScript("OnEscapePressed", function(self) self:GetParent():GetParent():Hide() end)
	scrollFrame:SetScrollChild(editBox)
	f.editBox = editBox

	return f
end

local exportDialog
local function OpenExportDialog(title, str)
	if not exportDialog then
		exportDialog = BuildTextDialog("AscensionDungeonMapperExportDialog", "Export Route")
		exportDialog.hint:SetText("Ctrl+A then Ctrl+C to copy the whole string:")

		local closeBtn = CreateActionButton(exportDialog, "Close", 80)
		closeBtn:SetPoint("BOTTOMRIGHT", exportDialog, "BOTTOMRIGHT", -14, 14)
		closeBtn:SetScript("OnClick", function() exportDialog:Hide() end)
	end
	exportDialog.titleText:SetText(title)
	exportDialog.editBox:SetText(str)
	exportDialog:Show()
	exportDialog.editBox:HighlightText()
	exportDialog.editBox:SetFocus()
end

local importDialog
local function OpenImportDialog()
	if not importDialog then
		importDialog = BuildTextDialog("AscensionDungeonMapperImportDialog", "Import Route")
		importDialog.hint:SetText("Paste a share string, then click Import:")

		local importBtn = CreateActionButton(importDialog, "Import", 80)
		importBtn:SetPoint("BOTTOMLEFT", importDialog, "BOTTOMLEFT", 14, 14)
		importBtn:SetScript("OnClick", function()
			DR.UI.HandleImport(importDialog.editBox:GetText())
			importDialog:Hide()
		end)

		local cancelBtn = CreateActionButton(importDialog, "Cancel", 80)
		cancelBtn:SetPoint("BOTTOMRIGHT", importDialog, "BOTTOMRIGHT", -14, 14)
		cancelBtn:SetScript("OnClick", function() importDialog:Hide() end)
	end
	importDialog.editBox:SetText("")
	importDialog:Show()
	importDialog.editBox:SetFocus()
end
DR.UI.OpenImportDialog = OpenImportDialog

local function ExportCurrent()
	if not currentDungeonKey then
		DR.Print("Select a dungeon first.")
		return
	end
	local name = currentRouteName or "Unsaved Route"
	local lines, points = DR.DrawEngine.GetRouteData()
	local routeData = {
		author = (UnitName("player") or "Unknown") .. "-" .. (GetRealmName() or ""),
		level = currentLevel,
		created = time(),
		updated = time(),
		lines = lines,
		points = points,
	}
	local str, err = DR.ShareExport.Export(currentDungeonKey, name, routeData)
	if not str then
		DR.Print("Export failed: " .. tostring(err))
		return
	end
	OpenExportDialog("Share string for \"" .. name .. "\"", str)
end

-- Draw-tool color picker: a small floating swatch row over the bottom of
-- the canvas, shown only while the Draw tool is active. Picking a color
-- doesn't touch strokes already drawn -- see DrawEngine's currentLineColor.

local COLOR_SWATCH_SIZE = 18

local function BuildColorPicker(parentCanvas)
	local colors = DR.DrawEngine.LINE_COLORS
	local picker = CreateFrame("Frame", nil, parentCanvas)
	picker:SetWidth(#colors * (COLOR_SWATCH_SIZE + 4) + 4)
	picker:SetHeight(COLOR_SWATCH_SIZE + 8)
	picker:SetPoint("BOTTOM", parentCanvas, "BOTTOM", 0, 6)
	picker:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 10,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	picker:SetBackdropColor(0, 0, 0, 0.6)
	picker:Hide()
	picker.buttons = {}

	for i, color in ipairs(colors) do
		local btn = CreateFrame("Button", nil, picker)
		btn:SetWidth(COLOR_SWATCH_SIZE)
		btn:SetHeight(COLOR_SWATCH_SIZE)
		btn:SetPoint("LEFT", picker, "LEFT", 2 + (i - 1) * (COLOR_SWATCH_SIZE + 4), 0)

		local tex = btn:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints(btn)
		tex:SetTexture(color[1], color[2], color[3], 1)

		btn.selectedBorder = CreateSelectionBorder(btn, 2)

		btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		btn:SetScript("OnClick", function()
			DR.DrawEngine.SetLineColor(color[1], color[2], color[3])
			for _, b in ipairs(picker.buttons) do
				if b == btn then b.selectedBorder:Show() else b.selectedBorder:Hide() end
			end
		end)

		picker.buttons[#picker.buttons + 1] = btn
	end
	picker.buttons[1].selectedBorder:Show() -- Blue is the default

	return picker
end

-- Main frame construction -----------------------------------------------

-- Everything right of the sidebar (header/canvas/toolbars) starts here.
-- UIPanelScrollFrameTemplate's scrollbar renders OUTSIDE the scroll frame's
-- own declared width (roughly another 18-20px to the right of it), so this
-- needs real clearance past the sidebar's right edge (14 + 226 = 240) or it
-- visually collides with the canvas -- 34px gets it well clear.
local CONTENT_X = 274

local function BuildMainFrame()
	local f = CreateBorderedFrame("AscensionDungeonMapperMainFrame", UIParent, 960, 730, "Ascension Dungeon Mapper")
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	f:Hide()

	-- CreateBorderedFrame centers the title over the whole frame by default,
	-- but the sidebar throws off that center relative to the dungeon-name
	-- header below it -- re-center over the same span (CONTENT_X..+CANVAS_W)
	-- so the two actually line up.
	f.titleText:ClearAllPoints()
	f.titleText:SetPoint("TOP", f, "TOPLEFT", CONTENT_X + CANVAS_W / 2, -14)

	-- Era buttons
	local eraLabels = { Classic = "Classic", TBC = "TBC", WotLK = "WotLK" }
	local prevBtn
	for _, era in ipairs(DR.Eras) do
		local btn = CreateActionButton(f, eraLabels[era], 80)
		if prevBtn then
			btn:SetPoint("LEFT", prevBtn, "RIGHT", 6, 0)
		else
			btn:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -30)
		end
		btn:SetScript("OnClick", function() SetEra(era) end)
		prevBtn = btn
	end

	-- Dungeon list (scroll frame)
	local scrollFrame = CreateFrame("ScrollFrame", "AscensionDungeonMapperDungeonScroll", f, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -62)
	scrollFrame:SetWidth(226)
	scrollFrame:SetHeight(600)
	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetWidth(210)
	content:SetHeight(1)
	scrollFrame:SetScrollChild(content)
	dungeonListContent = content

	-- Header (selected dungeon / route info)
	headerDungeonText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	headerDungeonText:SetPoint("TOPLEFT", f, "TOPLEFT", CONTENT_X, -34)
	headerDungeonText:SetWidth(CANVAS_W)
	headerDungeonText:SetJustifyH("CENTER")
	headerDungeonText:SetText("Select a dungeon or raid on the left")

	headerRouteText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	headerRouteText:SetPoint("TOPLEFT", headerDungeonText, "BOTTOMLEFT", 0, -4)
	headerRouteText:SetText("")

	-- Level controls -- anchored from the frame's right edge and chained
	-- leftward so < / > stay close together regardless of frame width.
	levelNext = CreateActionButton(f, ">", 24)
	levelNext:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, -34)
	levelNext:SetScript("OnClick", function() ChangeLevel(1) end)

	levelText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	levelText:SetPoint("RIGHT", levelNext, "LEFT", -2, 0)
	levelText:SetWidth(64)
	levelText:SetJustifyH("CENTER")

	levelPrev = CreateActionButton(f, "<", 24)
	levelPrev:SetPoint("RIGHT", levelText, "LEFT", -2, 0)
	levelPrev:SetScript("OnClick", function() ChangeLevel(-1) end)

	-- Canvas
	canvas = CreateFrame("Frame", "AscensionDungeonMapperCanvas", f)
	canvas:SetWidth(CANVAS_W)
	canvas:SetHeight(CANVAS_H)
	canvas:SetPoint("TOPLEFT", headerRouteText, "BOTTOMLEFT", 0, -10)
	canvas:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
	})

	DR.DrawEngine.Init(canvas)
	DR.DrawEngine.onPointClick = OpenPointEditor

	local colorPicker = BuildColorPicker(canvas)

	-- Toolbar: Draw/Point/Erase centered on row 1, Undo/Clear centered on
	-- row 2 directly beneath them.
	local TOOL_BUTTON_SIZE = 48
	local TOOL_GAP = 6
	local toolRowWidth = TOOL_BUTTON_SIZE * 3 + TOOL_GAP * 2
	local toolRowX = (CANVAS_W - toolRowWidth) / 2
	local undoClearWidth = 70 * 2 + TOOL_GAP
	local undoClearX = (CANVAS_W - undoClearWidth) / 2

	local toolbar = CreateFrame("Frame", nil, f)
	toolbar:SetPoint("TOPLEFT", canvas, "BOTTOMLEFT", 0, -10)
	toolbar:SetWidth(CANVAS_W)
	toolbar:SetHeight(TOOL_BUTTON_SIZE + 8 + 22)

	local function ModeButton(text, mode, prev)
		local btn = CreateActionButton(toolbar, text, TOOL_BUTTON_SIZE)
		btn:SetHeight(TOOL_BUTTON_SIZE)
		if prev then
			btn:SetPoint("LEFT", prev, "RIGHT", TOOL_GAP, 0)
		else
			btn:SetPoint("TOPLEFT", toolbar, "TOPLEFT", toolRowX, 0)
		end
		btn.selectedBorder = CreateSelectionBorder(btn, 6)
		btn:SetScript("OnClick", function()
			if DR.DrawEngine.GetMode() == mode then
				DR.DrawEngine.SetMode(nil)
			else
				DR.DrawEngine.SetMode(mode)
			end
			local activeMode = DR.DrawEngine.GetMode()
			SetModeButtonHighlight(activeMode)
			if activeMode == "line" then colorPicker:Show() else colorPicker:Hide() end
		end)
		modeButtons[mode] = btn
		return btn
	end

	local lineBtn = ModeButton("Draw", "line")
	local pointBtn = ModeButton("Marker", "point", lineBtn)
	local eraseBtn = ModeButton("Erase", "erase", pointBtn)

	local undoBtn = CreateActionButton(toolbar, "Undo", 70)
	undoBtn:SetPoint("TOPLEFT", toolbar, "TOPLEFT", undoClearX, -(TOOL_BUTTON_SIZE + 8))
	undoBtn:SetScript("OnClick", function() DR.DrawEngine.Undo() end)

	local clearBtn = CreateActionButton(toolbar, "Clear", 70)
	clearBtn:SetPoint("LEFT", undoBtn, "RIGHT", TOOL_GAP, 0)
	clearBtn:SetScript("OnClick", function() StaticPopup_Show("ASCENSIONDUNGEONMAPPER_CONFIRM_CLEAR") end)

	-- Second toolbar row: route box (left) + route management buttons (right)
	local ROUTE_ROW_HEIGHT = 16
	local ROUTE_BOX_WIDTH = 180
	local toolbar2 = CreateFrame("Frame", nil, f)
	toolbar2:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 0, -8)
	toolbar2:SetWidth(CANVAS_W)
	toolbar2:SetHeight(ROUTE_ROW_HEIGHT * MAX_ROUTES_PER_DUNGEON + 10)

	local routeBox = CreateFrame("Frame", nil, toolbar2)
	routeBox:SetPoint("LEFT", toolbar2, "LEFT", 0, 0)
	routeBox:SetWidth(ROUTE_BOX_WIDTH)
	routeBox:SetHeight(ROUTE_ROW_HEIGHT * MAX_ROUTES_PER_DUNGEON + 10)
	routeBox:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	routeBox:SetBackdropColor(0, 0, 0, 0.5)

	for i = 1, MAX_ROUTES_PER_DUNGEON do
		local slot = CreateFrame("Button", nil, routeBox)
		slot:SetWidth(ROUTE_BOX_WIDTH - 12)
		slot:SetHeight(ROUTE_ROW_HEIGHT)
		slot:SetPoint("TOPLEFT", routeBox, "TOPLEFT", 6, -5 - (i - 1) * ROUTE_ROW_HEIGHT)
		slot:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
		local fs = slot:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		fs:SetPoint("LEFT", slot, "LEFT", 2, 0)
		fs:SetJustifyH("LEFT")
		fs:SetWidth(ROUTE_BOX_WIDTH - 16)
		slot.text = fs
		-- Same reasoning as the dungeon list: a wide/short row, not the
		-- square action-button border -- use the quest-log selected-row
		-- texture instead.
		local selectedBar = slot:CreateTexture(nil, "OVERLAY")
		selectedBar:SetPoint("TOPLEFT", slot, "TOPLEFT", -2, 2)
		selectedBar:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 2, -2)
		selectedBar:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
		selectedBar:SetBlendMode("ADD")
		selectedBar:Hide()
		slot.selectedBorder = selectedBar
		routeBoxSlots[i] = slot
	end

	-- New/Save/Delete on one row, Export/Import centered beneath them. Both
	-- rows center within the full CANVAS_W, same as the Draw/Marker/Erase
	-- and Undo/Clear rows above -- centering within CANVAS_W always puts a
	-- row's midpoint at CANVAS_W/2 regardless of that row's own width, which
	-- is what actually keeps every row's center lined up with the toolbar
	-- above (centering each one only in the leftover space beside the route
	-- box, as before, gave each row a different center and the visible
	-- offset that was the point of the complaint).
	local row1Width = 100 + 6 + 70 + 6 + 70
	local row2Width = 80 + 6 + 80
	local row1X = (CANVAS_W - row1Width) / 2
	local row2X = (CANVAS_W - row2Width) / 2
	local buttonBlockTop = -(toolbar2:GetHeight() - (22 + 6 + 22)) / 2

	local newBtn = CreateActionButton(toolbar2, "New Route", 100)
	newBtn:SetPoint("TOPLEFT", toolbar2, "TOPLEFT", row1X, buttonBlockTop)
	newBtn:SetScript("OnClick", function()
		-- Only this button means "start over blank" -- clear here, before
		-- naming, rather than in CreateNewRoute (which Save's no-name-yet
		-- fallback also calls, and that path must NOT clear).
		DR.DrawEngine.Clear()
		StaticPopup_Show("ASCENSIONDUNGEONMAPPER_NEW_ROUTE")
	end)

	local saveBtn = CreateActionButton(toolbar2, "Save", 70)
	saveBtn:SetPoint("LEFT", newBtn, "RIGHT", 6, 0)
	saveBtn:SetScript("OnClick", SaveCurrentRoute)

	local deleteBtn = CreateActionButton(toolbar2, "Delete", 70)
	deleteBtn:SetPoint("LEFT", saveBtn, "RIGHT", 6, 0)
	deleteBtn:SetScript("OnClick", DeleteCurrentRoute)

	local exportBtn = CreateActionButton(toolbar2, "Export", 80)
	exportBtn:SetPoint("TOPLEFT", toolbar2, "TOPLEFT", row2X, buttonBlockTop - 22 - 6)
	exportBtn:SetScript("OnClick", ExportCurrent)

	local importBtn = CreateActionButton(toolbar2, "Import", 80)
	importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 6, 0)
	importBtn:SetScript("OnClick", function() DR.UI.OpenImportDialog() end)

	-- Credit + GitHub link, bottom-right corner of the window.
	local creditText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	creditText:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 14)
	creditText:SetText("Made by Gild")

	local githubBtn = CreateFrame("Button", nil, f)
	githubBtn:SetWidth(16)
	githubBtn:SetHeight(16)
	githubBtn:SetPoint("RIGHT", creditText, "LEFT", -6, 0)
	local githubTex = githubBtn:CreateTexture(nil, "ARTWORK")
	githubTex:SetAllPoints(githubBtn)
	-- No authentic GitHub logo ships with a 3.3.5 client -- this is a
	-- generic stand-in icon, not a real GitHub mark.
	githubTex:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
	githubBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	githubBtn:SetScript("OnClick", function() StaticPopup_Show("ASCENSIONDUNGEONMAPPER_GITHUB_LINK") end)
	githubBtn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText("View on GitHub", 1, 1, 1)
		GameTooltip:AddLine(GITHUB_URL, 0.6, 0.8, 1, true)
		GameTooltip:Show()
	end)
	githubBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

	local discordBtn = CreateFrame("Button", nil, f)
	discordBtn:SetWidth(16)
	discordBtn:SetHeight(16)
	discordBtn:SetPoint("RIGHT", githubBtn, "LEFT", -8, 0)
	local discordTex = discordBtn:CreateTexture(nil, "ARTWORK")
	discordTex:SetAllPoints(discordBtn)
	-- Built-in voice-chat speaker icon -- reads as "speaker" without
	-- needing a bundled custom texture.
	discordTex:SetTexture("Interface\\Common\\VoiceChat-Speaker")
	discordBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	discordBtn:SetScript("OnClick", function() StaticPopup_Show("ASCENSIONDUNGEONMAPPER_DISCORD_LINK") end)
	discordBtn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText("Join the Discord", 1, 1, 1)
		GameTooltip:AddLine(DISCORD_URL, 0.6, 0.8, 1, true)
		GameTooltip:Show()
	end)
	discordBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

	SetModeButtonHighlight(nil)
	RefreshRouteBox()
	return f
end

-- Entry points -----------------------------------------------------------

function DR.ToggleMainFrame()
	if not mainFrame then
		mainFrame = BuildMainFrame()
		RefreshDungeonList()
	end
	if mainFrame:IsShown() then
		mainFrame:Hide()
	else
		mainFrame:Show()
		DR.TryDiscoverCurrentInstance()
		RefreshDungeonList()
	end
end

function DR.OnSavedVariablesReady()
	if DR.InitMinimapIcon then
		DR.InitMinimapIcon()
	end
end
