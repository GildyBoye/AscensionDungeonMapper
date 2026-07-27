AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper

local discoveryFrame = CreateFrame("Frame")
discoveryFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
discoveryFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local function ReadCurrentMapID()
	SetMapToCurrentZone()
	return GetCurrentMapAreaID() - 1
end

local function Bootstrap()
	if DR.db.bootstrapped then return end

	local skipped = DR.WithSavedMapState(function()
		for key, defaultID in pairs(DR.DefaultMapIDs) do
			if not DR.GetKnownMap(key) then
				SetMapByID(defaultID)
				local mapFileName = GetMapInfo()
				if mapFileName then
					local numLevels = GetNumDungeonMapLevels()
					DR.SetKnownMap(key, defaultID, numLevels)
				end
			end
		end
	end)

	if not skipped then
		DR.db.bootstrapped = true
	end
end
DR.Bootstrap = Bootstrap

local function TryDiscoverCurrentInstance()
	if WorldMapFrame and WorldMapFrame:IsShown() then return end

	local inInstance = IsInInstance()

	if not inInstance then
		local mapID = ReadCurrentMapID()
		if mapID and mapID >= 0 then
			DR.SetLastOutdoorZoneMapID(mapID)
		end
		return
	end

	local instanceName = GetInstanceInfo()
	local normalized = DR.NormalizeName(instanceName)
	local key = DR.KeyByNormalizedName[normalized]
	if not key then
		return
	end

	local already = DR.GetKnownMap(key)
	local mapID = ReadCurrentMapID()
	local numLevels = GetNumDungeonMapLevels()
	local outsideZoneMapID = DR.GetLastOutdoorZoneMapID()

	if not already or already.mapID ~= mapID or already.numLevels ~= numLevels
		or (outsideZoneMapID and already.outsideZoneMapID ~= outsideZoneMapID) then
		DR.SetKnownMap(key, mapID, numLevels, outsideZoneMapID)
		if not already then
			DR.Print(("Learned the map for %s -- it'll be available next time you open the addon."):format(DR.DungeonByKey[key].name))
		end
	end
end

discoveryFrame:SetScript("OnEvent", function(self, event)
	if not DR.db then return end
	Bootstrap()
	TryDiscoverCurrentInstance()
end)

DR.TryDiscoverCurrentInstance = TryDiscoverCurrentInstance
