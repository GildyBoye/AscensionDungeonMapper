AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper

DR.ADDON_NAME = "AscensionDungeonMapper"

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff3fc7ebAscensionDungeonMapper|r: " .. tostring(msg))
end
DR.Print = Print

function DR.Trim(s)
	return (s or ""):match("^%s*(.-)%s*$")
end

-- Strips WoW's "|"-prefixed formatting/hyperlink escape codes. Applied to
-- any free-text field coming from an untrusted import (route name, marker
-- title/text) before it's saved, since those fields get displayed through
-- SetText/GameTooltip calls that interpret those codes -- without this, a
-- crafted route name could fake colored "system" text or fake links in
-- whoever previews or imports it.
function DR.StripFormatting(s)
	if type(s) ~= "string" then return "" end
	return (s:gsub("|", ""))
end

local function InitializeSavedVariables()
	if type(AscensionDungeonMapperDB) ~= "table" then
		AscensionDungeonMapperDB = {}
	end
	local db = AscensionDungeonMapperDB
	db.version = db.version or 1
	db.knownMaps = db.knownMaps or {}
	db.routes = db.routes or {}
	DR.db = db
end

function DR.GetKnownMap(dungeonKey)
	return DR.db.knownMaps[dungeonKey]
end

function DR.SetKnownMap(dungeonKey, mapID, numLevels, outsideZoneMapID)
	local existing = DR.db.knownMaps[dungeonKey]
	DR.db.knownMaps[dungeonKey] = {
		mapID = mapID,
		numLevels = numLevels or 0,
		outsideZoneMapID = outsideZoneMapID or (existing and existing.outsideZoneMapID),
	}
end

function DR.GetLastOutdoorZoneMapID()
	return DR.db.lastOutdoorZoneMapID
end

function DR.SetLastOutdoorZoneMapID(mapID)
	DR.db.lastOutdoorZoneMapID = mapID
end

function DR.WithSavedMapState(fn)
	if WorldMapFrame and WorldMapFrame:IsShown() then
		return true, nil
	end

	local prevAreaID = GetCurrentMapAreaID()
	local prevDungeonLevel = GetCurrentMapDungeonLevel()
	local prevContinent = GetCurrentMapContinent()
	local prevZone = GetCurrentMapZone()

	local results = { pcall(fn) }
	local ok = table.remove(results, 1)

	if prevAreaID and prevAreaID > 1 then
		SetMapByID(prevAreaID - 1)
		if prevDungeonLevel and prevDungeonLevel > 0 then
			SetDungeonMapLevel(prevDungeonLevel)
		end
	elseif prevContinent then
		SetMapZoom(prevContinent, prevZone)
	end

	if not ok then
		error(results[1])
	end
	return false, unpack(results)
end

function DR.GetRoutesForDungeon(dungeonKey)
	return DR.db.routes[dungeonKey] or {}
end

function DR.SaveRoute(dungeonKey, routeName, routeData)
	DR.db.routes[dungeonKey] = DR.db.routes[dungeonKey] or {}
	DR.db.routes[dungeonKey][routeName] = routeData
end

function DR.DeleteRoute(dungeonKey, routeName)
	if DR.db.routes[dungeonKey] then
		DR.db.routes[dungeonKey][routeName] = nil
	end
end

function DR.RenameRoute(dungeonKey, oldName, newName)
	local routes = DR.db.routes[dungeonKey]
	if not routes or not routes[oldName] or routes[newName] then
		return false
	end
	routes[newName] = routes[oldName]
	routes[oldName] = nil
	return true
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
	if event == "ADDON_LOADED" and addonName == DR.ADDON_NAME then
		InitializeSavedVariables()
		self:UnregisterEvent("ADDON_LOADED")
		if DR.OnSavedVariablesReady then
			DR.OnSavedVariablesReady()
		end
	end
end)

SLASH_ASCENSIONDUNGEONMAPPER1 = "/adm"
SLASH_ASCENSIONDUNGEONMAPPER2 = "/dungeonmapper"
SLASH_ASCENSIONDUNGEONMAPPER3 = "/dr"

SlashCmdList["ASCENSIONDUNGEONMAPPER"] = function(msg)
	msg = DR.Trim((msg or ""):lower())
	if msg == "debug" then
		local inInstance, instanceType = IsInInstance()
		if not inInstance then
			Print("You are not inside an instance.")
			return
		end
		local name = GetInstanceInfo()
		SetMapToCurrentZone()
		local areaID = GetCurrentMapAreaID()
		local numLevels = GetNumDungeonMapLevels()
		local currentLevel = GetCurrentMapDungeonLevel()
		local liveID = areaID - 1
		local key = DR.KeyByNormalizedName[DR.NormalizeName(name)]
		local cached = key and DR.GetKnownMap(key)
		local defaultID = key and DR.DefaultMapIDs[key]
		Print(("Instance: %s | key: %s | live mapID: %d | cached mapID: %s | DefaultMapIDs: %s | dungeon levels: %d | current level: %d"):format(
			name, key or "(unmatched)", liveID,
			cached and tostring(cached.mapID) or "none",
			defaultID and tostring(defaultID) or "none",
			numLevels, currentLevel))
	elseif msg == "resetmaps" then
		DR.db.knownMaps = {}
		DR.db.bootstrapped = nil
		Print("Cleared all cached map IDs. They'll be re-learned from the current DefaultMapIDs table and by walking into instances.")
	else
		if DR.ToggleMainFrame then
			DR.ToggleMainFrame()
		end
	end
end
