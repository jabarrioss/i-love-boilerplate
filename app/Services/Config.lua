--[[
    Config.lua — runtime configuration loader.

    All game/control/audio settings live in /config/*.lua files
    and are loaded once at boot. Access them anywhere via:

        config = app:config()
        config:get("game.window.title", "Default Title")
        config:get("input.bindings.jump")   -- "space"
        config:set("game.debug", true)      -- override at runtime
]]

local Class = require("core.Class")

local Config = Class:extend("Config")

function Config:new(app)
    self.app = app
    self._store = {}
    self._files = {
        "app",
        "game",
        "input",
        "audio",
        "scenes",
    }
    self:load()
    return self
end

function Config:load()
    for _, name in ipairs(self._files) do
        local ok, tbl = pcall(require, "config." .. name)
        if ok and type(tbl) == "table" then
            self._store[name] = tbl
        elseif not ok then
            -- First boot may not have all config files; warn but don't fail.
            io.stderr:write(("[Config] optional config/%s.lua not loaded: %s\n"):format(name, tostring(tbl)))
        else
            self._store[name] = {}
        end
    end
    return self
end

-- config:get("game.window.title", "fallback")
-- supports dotted keys. Last segment can be an array index.
function Config:get(path, default)
    assert(type(path) == "string", "Config:get requires a string path")
    local parts = {}
    for part in path:gmatch("[^.]+") do
        table.insert(parts, part)
    end

    -- parts[1] is the file key, parts[2..] is the dotted path inside it.
    local current = self._store[parts[1]]
    for i = 2, #parts do
        if current == nil then return default end
        local key = parts[i]
        -- numeric index support: "enemies.list.1" -> enemies.list[1]
        if tonumber(key) then key = tonumber(key) end
        current = current[key]
    end
    if current == nil then return default end
    return current
end

function Config:set(path, value)
    assert(type(path) == "string", "Config:set requires a string path")
    local parts = {}
    for part in path:gmatch("[^.]+") do
        table.insert(parts, part)
    end
    local root = parts[1]
    self._store[root] = self._store[root] or {}
    local node = self._store[root]
    for i = 2, #parts - 1 do
        local key = tonumber(parts[i]) or parts[i]
        node[key] = node[key] or {}
        node = node[key]
    end
    local lastKey = tonumber(parts[#parts]) or parts[#parts]
    node[lastKey] = value
    return self
end

function Config:all(file)
    if file then return self._store[file] end
    return self._store
end

function Config:reload()
    self._store = {}
    self:load()
    return self
end

return Config
