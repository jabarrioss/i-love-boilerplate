--[[
    Utils/string.lua — string utilities.
]]

local M = {}

function M.startsWith(s, prefix)
    return type(s) == "string" and type(prefix) == "string" and s:sub(1, #prefix) == prefix
end

function M.endsWith(s, suffix)
    return type(s) == "string" and type(suffix) == "string" and s:sub(-#suffix) == suffix
end

function M.split(s, sep)
    local out = {}
    sep = sep or ","
    local pattern = "([^" .. sep .. "]+)"
    for piece in s:gmatch(pattern) do table.insert(out, piece) end
    return out
end

function M.trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.pad(s, len, char)
    char = char or " "
    s = tostring(s)
    if #s >= len then return s end
    return s .. string.rep(char, len - #s)
end

function M.padLeft(s, len, char)
    char = char or " "
    s = tostring(s)
    if #s >= len then return s end
    return string.rep(char, len - #s) .. s
end

function M.formatNumber(n, decimals, sep)
    decimals = decimals or 0
    sep = sep or ","
    local fmt = string.format("%%.%df", decimals)
    local s = string.format(fmt, n)
    local intPart, decPart = s:match("^(%-?%d+)(%.?.*)$")
    intPart = intPart:reverse():gsub("(%d%d%d)", "%1" .. sep):reverse()
    if intPart:sub(1, 1) == sep then intPart = intPart:sub(2) end
    return intPart .. decPart
end

function M.uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return (template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end))
end

return M
