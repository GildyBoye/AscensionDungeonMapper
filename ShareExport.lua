AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper
DR.ShareExport = {}

local PREFIX = "DR1:"

local MAX_INPUT_LEN = 100000
local MAX_DECOMPRESSED_LEN = 200000
local MAX_LINES = 5000
local MAX_POINTS = 500
local MAX_ROUTE_LEVELS = 20

local function TrimString(s)
	return s:match("^%s*(.-)%s*$")
end

local function GetLibDeflate()
	if LibStub then
		return LibStub:GetLibrary("LibDeflate", true)
	end
	return _G.LibDeflate
end

function DR.ShareExport.Export(dungeonKey, routeName, routeData)
	local LibDeflate = GetLibDeflate()
	if not LibDeflate then
		return nil, "LibDeflate not loaded"
	end

	local package = {
		v = 1,
		dk = dungeonKey,
		rn = routeName,
		rd = routeData,
	}

	local ok, serialized = pcall(function() return DR.Serializer:Serialize(package) end)
	if not ok then
		return nil, "failed to serialize route: " .. tostring(serialized)
	end

	local compressed = LibDeflate:CompressDeflate(serialized, { level = 9 })
	local encoded = LibDeflate:EncodeForPrint(compressed)
	return PREFIX .. encoded
end

function DR.ShareExport.Import(str)
	local LibDeflate = GetLibDeflate()
	if not LibDeflate then
		return false, nil, nil, nil, "LibDeflate not loaded"
	end

	if type(str) ~= "string" then
		return false, nil, nil, nil, "no data given"
	end
	if #str > MAX_INPUT_LEN then
		return false, nil, nil, nil, "that's way too long to be a real share string"
	end
	str = TrimString(str)
	if str:sub(1, #PREFIX) ~= PREFIX then
		return false, nil, nil, nil, "doesn't look like a AscensionDungeonMapper share string"
	end
	local encoded = str:sub(#PREFIX + 1)

	local compressed = LibDeflate:DecodeForPrint(encoded)
	if not compressed then
		return false, nil, nil, nil, "couldn't decode string (was it copied fully?)"
	end

	local serialized = LibDeflate:DecompressDeflate(compressed)
	if not serialized then
		return false, nil, nil, nil, "couldn't decompress string (was it copied fully?)"
	end
	if #serialized > MAX_DECOMPRESSED_LEN then
		return false, nil, nil, nil, "decompressed route data is implausibly large"
	end

	local ok, package = DR.Serializer:Deserialize(serialized)
	if not ok then
		return false, nil, nil, nil, "corrupt route data: " .. tostring(package)
	end

	if type(package) ~= "table" or package.v ~= 1 or type(package.dk) ~= "string"
		or type(package.rn) ~= "string" or type(package.rd) ~= "table" then
		return false, nil, nil, nil, "unrecognized route data format"
	end

	if not DR.DungeonByKey[package.dk] then
		return false, nil, nil, nil, "this route is for a dungeon this addon version doesn't know about"
	end

	local levels = DR.NormalizeRouteLevels(package.rd)
	local levelCount = 0
	for _, lvl in pairs(levels) do
		levelCount = levelCount + 1
		if levelCount > MAX_ROUTE_LEVELS then
			return false, nil, nil, nil, "this route has an implausible number of levels"
		end
		if type(lvl) ~= "table" then
			return false, nil, nil, nil, "corrupt route data"
		end
		lvl.lines = lvl.lines or {}
		lvl.points = lvl.points or {}
		if #lvl.lines > MAX_LINES or #lvl.points > MAX_POINTS then
			return false, nil, nil, nil, "this route has an implausible number of lines/points"
		end
		for _, p in ipairs(lvl.points) do
			p.title = DR.StripFormatting(p.title)
			p.text = DR.StripFormatting(p.text)
		end
	end
	package.rd.levels = levels
	package.rd.lines = nil
	package.rd.points = nil

	package.rn = DR.StripFormatting(package.rn)

	return true, package.dk, package.rn, package.rd
end
