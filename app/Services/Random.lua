--[[
    Random.lua — seedable PRNG (LCG) + helpers.

    By default it wraps love.math.random so you can also call
    :seed(42) for reproducible runs (replays, testing, daily seeds).

        random = app:random()
        random:seed(os.time())
        dice = random:integer(1, 6)
        chance = random:chance(0.25)        -- 25% true
        pick = random:pick({"a", "b", "c"})
        list = random:shuffle({1, 2, 3, 4})
]]

local Class = require("core.Class")

local Random = Class:extend("Random")

function Random:new(app)
    self.app = app
    self._state = 0
    self._useLua = true
    if app and app:config():get("app.random.seed") then
        self:seed(app:config():get("app.random.seed"))
    end
    return self
end

function Random:seed(value)
    if value == nil then value = os.time() end
    if love and love.math then
        love.math.setRandomSeed(value)
    end
    self._state = tonumber(value) or 0
    return self
end

function Random:number(min, max)
    if not min then return love.math.random() end
    if not max then return love.math.random() * min end
    return love.math.random(min, max)
end

function Random:integer(min, max)
    return love.math.random(min, max)
end

function Random:chance(p)
    return love.math.random() < p
end

function Random:pick(list)
    assert(type(list) == "table", "Random:pick requires a table")
    local n = #list
    if n == 0 then return nil end
    return list[love.math.random(n)]
end

function Random:weighted(items)
    -- items = { { weight = 1, value = "common" }, { weight = 0.1, value = "rare" } }
    local total = 0
    for _, it in ipairs(items) do total = total + (it.weight or 1) end
    local r = love.math.random() * total
    local acc = 0
    for _, it in ipairs(items) do
        acc = acc + (it.weight or 1)
        if r <= acc then return it.value end
    end
    return items[#items].value
end

function Random:shuffle(list)
    local copy = {}
    for i, v in ipairs(list) do copy[i] = v end
    for i = #copy, 2, -1 do
        local j = love.math.random(i)
        copy[i], copy[j] = copy[j], copy[i]
    end
    return copy
end

-- Standard normal via Box–Muller.
function Random:normal(mean, stddev)
    mean = mean or 0
    stddev = stddev or 1
    local u1 = math.max(1e-12, love.math.random())
    local u2 = love.math.random()
    local z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return z * stddev + mean
end

return Random
