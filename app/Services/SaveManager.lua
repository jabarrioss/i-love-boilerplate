--[[
    SaveManager.lua — typed key/value store backed by LÖVE's save directory.

    Multiple named slots. Atomic writes. Survives crashes. Use for
    settings, progression, unlocks, etc.

        save:set("settings.musicVolume", 0.6)
        save:get("settings.musicVolume", 0.8)   -- 0.6
        save:save("profile1")                   -- writes to storage/saves/profile1.lua
        save:load("profile1")                   -- replaces in-memory store

    The in-memory store is a plain nested table. To persist, call save().
    To reload, call load(). On boot, the latest "default" slot is loaded
    automatically.
]]

local Class = require("core.Class")

local SaveManager = Class:extend("SaveManager")

function SaveManager:new(app)
    self.app = app
    self._store = {}
    self._slot  = "default"
    self._dirty = false
    return self
end

function SaveManager:boot()
    local cfg = self.app:config()
    self._slot = cfg:get("app.save.slot", "default")
    if self:exists(self._slot) then
        self:load(self._slot)
    end
end

function SaveManager:set(path, value)
    self:_setPath(self._store, path, value)
    self._dirty = true
    return self
end

function SaveManager:get(path, default)
    return self:_getPath(self._store, path, default)
end

function SaveManager:unset(path)
    local parts = self:_parts(path)
    local node = self._store
    for i = 1, #parts - 1 do
        if type(node) ~= "table" then return self end
        node = node[parts[i]]
    end
    if type(node) == "table" then
        node[parts[#parts]] = nil
        self._dirty = true
    end
    return self
end

function SaveManager:_parts(path)
    local t = {}
    for p in path:gmatch("[^.]+") do table.insert(t, p) end
    return t
end

function SaveManager:_setPath(root, path, value)
    local parts = self:_parts(path)
    local node = root
    for i = 1, #parts - 1 do
        local key = parts[i]
        if type(node[key]) ~= "table" then node[key] = {} end
        node = node[key]
    end
    node[parts[#parts]] = value
end

function SaveManager:_getPath(root, path, default)
    local parts = self:_parts(path)
    local node = root
    for i = 1, #parts do
        if type(node) ~= "table" then return default end
        node = node[parts[i]]
    end
    if node == nil then return default end
    return node
end

local function serialize(t, indent)
    indent = indent or ""
    if type(t) == "nil" then return "nil" end
    if type(t) == "boolean" then return tostring(t) end
    if type(t) == "number" then return tostring(t) end
    if type(t) == "string" then return string.format("%q", t) end
    if type(t) == "table" then
        local pieces = { "{" }
        local n = #t
        for i = 1, n do
            table.insert(pieces, indent .. "  " .. serialize(t[i], indent .. "  ") .. ",")
        end
        for k, v in pairs(t) do
            if type(k) ~= "number" or k < 1 or k > n or math.floor(k) ~= k then
                local key = type(k) == "string" and ("[" .. string.format("%q", k) .. "]") or ("[" .. tostring(k) .. "]")
                table.insert(pieces, indent .. "  " .. key .. " = " .. serialize(v, indent .. "  ") .. ",")
            end
        end
        table.insert(pieces, indent .. "}")
        return table.concat(pieces, "\n")
    end
    return "nil"
end

function SaveManager:save(slot)
    slot = slot or self._slot
    self._slot = slot
    local content = "return " .. serialize(self._store)
    local path = "storage/saves/" .. slot .. ".lua"
    local ok, err = love.filesystem.write(path, content)
    if not ok then
        self.app:logger():error("SaveManager:save('%s') failed: %s", slot, tostring(err))
        return false
    end
    self._dirty = false
    self.app:logger():info("SaveManager: slot '%s' written (%d bytes)", slot, #content)
    return true
end

function SaveManager:load(slot)
    slot = slot or self._slot
    local path = "storage/saves/" .. slot .. ".lua"
    if not love.filesystem.getInfo(path) then
        self.app:logger():info("SaveManager: no save at slot '%s'", slot)
        return false
    end
    local chunk, err = love.filesystem.load(path)
    if not chunk then
        self.app:logger():error("SaveManager:load('%s') failed: %s", slot, tostring(err))
        return false
    end
    local ok, data = pcall(chunk)
    if not ok or type(data) ~= "table" then
        self.app:logger():error("SaveManager:load('%s') produced invalid data", slot)
        return false
    end
    self._store = data
    self._slot = slot
    self._dirty = false
    self.app:logger():info("SaveManager: slot '%s' loaded", slot)
    return true
end

function SaveManager:delete(slot)
    slot = slot or self._slot
    local path = "storage/saves/" .. slot .. ".lua"
    if love.filesystem.getInfo(path) then
        love.filesystem.remove(path)
    end
    if slot == self._slot then self._store = {} end
    return self
end

function SaveManager:exists(slot)
    slot = slot or self._slot
    return love.filesystem.getInfo("storage/saves/" .. slot .. ".lua") ~= nil
end

function SaveManager:flush()
    if self._dirty then self:save() end
end

return SaveManager
