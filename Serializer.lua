-- AscensionDungeonMapper Serializer
--
-- Import strings come from OTHER PLAYERS and must be treated as untrusted input.
-- We never use loadstring()/load() on them. Instead this is a small hand-written
-- recursive-descent encoder/decoder for a limited set of value types:
-- nil, true, false, numbers, strings, and nested tables (used as arrays or maps).
--
-- Wire format (no delimiters that need escaping -- everything is length-prefixed):
--   nil    -> "n"
--   true   -> "T"
--   false  -> "F"
--   number -> "N" <tostring(number)> ";"
--   string -> "S" <byte length> ":" <raw bytes>
--   table  -> "{" <entry count> ":" (key value)*count "}"
--
-- Table keys/values are themselves encoded with the same rules, so tables can
-- nest arbitrarily. This intentionally cannot represent functions, userdata,
-- or non-serializable values -- which is exactly what we want for shared data.

AscensionDungeonMapper = AscensionDungeonMapper or {}
local DR = AscensionDungeonMapper

local Serializer = {}
DR.Serializer = Serializer

local function encodeValue(value, parts)
	local t = type(value)
	if value == nil then
		parts[#parts + 1] = "n"
	elseif t == "boolean" then
		parts[#parts + 1] = value and "T" or "F"
	elseif t == "number" then
		parts[#parts + 1] = "N" .. string.format("%.17g", value) .. ";"
	elseif t == "string" then
		parts[#parts + 1] = "S" .. #value .. ":" .. value
	elseif t == "table" then
		-- Collect entries first so we know the count.
		local entryParts = {}
		local count = 0
		for k, v in pairs(value) do
			count = count + 1
			encodeValue(k, entryParts)
			encodeValue(v, entryParts)
		end
		parts[#parts + 1] = "{" .. count .. ":"
		for i = 1, #entryParts do
			parts[#parts + 1] = entryParts[i]
		end
		parts[#parts + 1] = "}"
	else
		error("AscensionDungeonMapper.Serializer: cannot serialize value of type " .. t)
	end
end

-- Serialize(value) -> string
function Serializer:Serialize(value)
	local parts = {}
	encodeValue(value, parts)
	return table.concat(parts)
end

-- Internal: decode one value starting at str[pos], return value, nextPos.
-- Throws (via error()) on any malformed input; callers must wrap in pcall.
local function decodeValue(str, pos)
	local tag = str:sub(pos, pos)
	if tag == "n" then
		return nil, pos + 1
	elseif tag == "T" then
		return true, pos + 1
	elseif tag == "F" then
		return false, pos + 1
	elseif tag == "N" then
		local semi = str:find(";", pos + 1, true)
		if not semi then error("truncated number") end
		local numStr = str:sub(pos + 1, semi - 1)
		local num = tonumber(numStr)
		if not num then error("invalid number literal: " .. tostring(numStr)) end
		return num, semi + 1
	elseif tag == "S" then
		local colon = str:find(":", pos + 1, true)
		if not colon then error("truncated string header") end
		local lenStr = str:sub(pos + 1, colon - 1)
		local len = tonumber(lenStr)
		if not len or len < 0 then error("invalid string length: " .. tostring(lenStr)) end
		local strStart = colon + 1
		local strEnd = strStart + len - 1
		if strEnd > #str then error("truncated string body") end
		return str:sub(strStart, strEnd), strEnd + 1
	elseif tag == "{" then
		local colon = str:find(":", pos + 1, true)
		if not colon then error("truncated table header") end
		local countStr = str:sub(pos + 1, colon - 1)
		local count = tonumber(countStr)
		if not count or count < 0 then error("invalid table entry count: " .. tostring(countStr)) end
		local result = {}
		local cursor = colon + 1
		for _ = 1, count do
			local key
			key, cursor = decodeValue(str, cursor)
			local val
			val, cursor = decodeValue(str, cursor)
			result[key] = val
		end
		if str:sub(cursor, cursor) ~= "}" then error("missing closing brace") end
		return result, cursor + 1
	else
		error("unknown type tag: " .. tostring(tag) .. " at position " .. pos)
	end
end

-- Deserialize(str) -> success(bool), value_or_errorMessage
function Serializer:Deserialize(str)
	if type(str) ~= "string" or str == "" then
		return false, "empty input"
	end
	local ok, result = pcall(function()
		local value, nextPos = decodeValue(str, 1)
		if nextPos ~= #str + 1 then
			error("trailing data after top-level value")
		end
		return value
	end)
	if not ok then
		return false, result
	end
	return true, result
end
