-- AscensionDungeonMapper MapDiscovery
--
-- Blizzard's client has no "list every instance's map ID" API, and the correct
-- IDs vary by client/server data, so we don't hardcode them. Instead: the first
-- time a player walks into a given instance, we read the ID the game itself is
-- using right then (GetCurrentMapAreaID()) and cache it. From then on we can
-- jump straight to that instance's map via SetMapByID() without being there.
--
-- Confirmed mechanics (from the 3.3.5 FrameXML source):
--   SetMapByID(GetCurrentMapAreaID() - 1) round-trips to the same map, so the
--   value we cache is GetCurrentMapAreaID() - 1.

AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper

local discoveryFrame = CreateFrame("Frame")
discoveryFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
discoveryFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local function ReadCurrentMapID()
	SetMapToCurrentZone()
	return GetCurrentMapAreaID() - 1
end

-- Bootstrap(): populate knownMaps from DR.DefaultMapIDs for anything we
-- haven't discovered yet, with zero requirement to have visited. Each ID is
-- sanity-checked against GetMapInfo() before being trusted -- if it doesn't
-- resolve to a real map on this server/client, it's silently skipped rather
-- than caching something wrong.
--
-- Runs once (tracked via DR.db.bootstrapped) but will keep retrying on
-- subsequent zone events until it actually gets a turn, since it's skipped
-- for any pass where the real WorldMapFrame happens to be open.
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
	-- Avoid fighting with a currently-open world map -- SetMapToCurrentZone()
	-- would visibly change what it's showing. Just try again on the next event.
	if WorldMapFrame and WorldMapFrame:IsShown() then return end

	local inInstance = IsInInstance()

	if not inInstance then
		-- Not in an instance: just remember this as "the last outdoor zone
		-- the player stood in". If they next zone into a dungeon with no
		-- interior map art, this is what we'll clone as a backdrop.
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
		-- Not one of the instances we track (e.g. a scenario, random
		-- battleground map, etc.) -- nothing to do.
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
	-- Small delay isn't strictly needed for these events, but guard against
	-- being called before SavedVariables are loaded on very first PLAYER_ENTERING_WORLD.
	if not DR.db then return end
	Bootstrap()
	TryDiscoverCurrentInstance()
end)

-- Also expose a manual trigger for the "/dr debug" style workflows or a
-- "Refresh" button in the UI.
DR.TryDiscoverCurrentInstance = TryDiscoverCurrentInstance
