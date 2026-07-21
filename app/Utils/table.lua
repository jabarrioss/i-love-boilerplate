--[[
    Utils/table.lua — table utilities. Pure, no LÖVE.
]]

local M = {}

function M.shallowCopy(t)
    local out = {}
    for k, v in pairs(t) do out[k] = v end
    return out
end

function M.deepCopy(t)
    if type(t) ~= "table" then return t end
    local out = {}
    for k, v in pairs(t) do out[k] = M.deepCopy(v) end
    return setmetatable(out, getmetatable(t))
end

function M.merge(...)
    local out = {}
    for _, t in ipairs({ ... }) do
        if type(t) == "table" then
            for k, v in pairs(t) do out[k] = v end
        end
    end
    return out
end

function M.deepMerge(...)
    local out = {}
    for _, t in ipairs({ ... }) do
        if type(t) == "table" then
            for k, v in pairs(t) do
                if type(v) == "table" and type(out[k]) == "table" then
                    out[k] = M.deepMerge(out[k], v)
                else
                    out[k] = v
                end
            end
        end
    end
    return out
end

function M.contains(t, value)
    for _, v in pairs(t) do if v == value then return true end end
    return false
end

function M.find(t, predicate)
    for i, v in ipairs(t) do
        if predicate(v, i) then return v, i end
    end
    return nil
end

function M.filter(t, predicate)
    local out = {}
    for i, v in ipairs(t) do
        if predicate(v, i) then table.insert(out, v) end
    end
    return out
end

function M.map(t, mapper)
    local out = {}
    for i, v in ipairs(t) do out[i] = mapper(v, i) end
    return out
end

function M.reduce(t, reducer, initial)
    local acc = initial
    for i, v in ipairs(t) do acc = reducer(acc, v, i) end
    return acc
end

function M.size(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

function M.keys(t)
    local out = {}
    for k in pairs(t) do table.insert(out, k) end
    return out
end

function M.values(t)
    local out = {}
    for _, v in pairs(t) do table.insert(out, v) end
    return out
end

function M.count(t, predicate)
    local n = 0
    for i, v in ipairs(t) do if predicate(v, i) then n = n + 1 end end
    return n
end

function M.tostring(t, indent)
    indent = indent or ""
    local pieces = { "{" }
    for k, v in pairs(t) do
        local key = type(k) == "string" and ('["' .. k .. '"]') or ("[" .. tostring(k) .. "]")
        local val
        if type(v) == "table" then
            val = M.tostring(v, indent .. "  ")
        elseif type(v) == "string" then
            val = '"' .. v .. '"'
        else
            val = tostring(v)
        end
        table.insert(pieces, indent .. "  " .. key .. " = " .. val .. ",")
    end
    table.insert(pieces, indent .. "}")
    return table.concat(pieces, "\n")
end

return M
