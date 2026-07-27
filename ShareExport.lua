AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper
DR.ShareExport = {}

local PREFIX = "DR1:"

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

	package.rd.lines = package.rd.lines or {}
	package.rd.points = package.rd.points or {}

	return true, package.dk, package.rn, package.rd
end
