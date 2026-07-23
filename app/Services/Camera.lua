--[[
    Camera.lua — 2D viewport with smooth follow, shake, and zoom.

    Use as:
        camera:follow(player)        -- track an entity by reference
        camera:followPoint(x, y)     -- or just a coordinate
        camera:screenshake(0.4, 8)   -- magnitude, duration
        camera:zoom(1.5)             -- 1.0 = normal
        camera:attach()              -- call at start of :draw
        -- ... draw world ...
        camera:detach()              -- call before drawing UI
]]

local Class = require("core.Class")

local Camera = Class:extend("Camera")

function Camera:new(app)
    local instance = setmetatable({}, self)
    instance.app = app
    local w, h = 1280, 720
    if love and love.graphics then
        w, h = love.graphics.getDimensions()
    end
    instance.x, instance.y   = w / 2, h / 2
    instance._zoom           = 1
    instance.rotation        = 0
    instance.following       = nil   -- entity or { x=, y= } ref
    instance.followLerp      = 4
    instance._shake          = { magnitude = 0, duration = 0, elapsed = 0 }
    instance._offset         = { x = 0, y = 0 }
    return instance
end

function Camera:resize(w, h)
    -- Keep camera centered if the user hasn't moved it
    if not self._userMoved then
        self.x, self.y = w / 2, h / 2
    end
end

function Camera:follow(target, lerp)
    self.following = target
    if lerp then self.followLerp = lerp end
    return self
end

function Camera:followPoint(x, y, lerp)
    self.following = { x = x, y = y }
    if lerp then self.followLerp = lerp end
    return self
end

function Camera:stopFollow()
    self.following = nil
    return self
end

function Camera:moveTo(x, y)
    self.x, self.y = x, y
    self._userMoved = true
    return self
end

function Camera:moveBy(dx, dy)
    self.x, self.y = self.x + dx, self.y + dy
    self._userMoved = true
    return self
end

function Camera:zoom(z)
    if z == nil then return self._zoom end
    self._zoom = math.max(0.01, z)
    return self
end

function Camera:rotate(r)
    self.rotation = r
    return self
end

function Camera:screenshake(magnitude, duration)
    self._shake = { magnitude = magnitude, duration = duration, elapsed = 0 }
    return self
end

function Camera:_applyShake(dt)
    local s = self._shake
    if s.duration <= 0 then self._offset.x, self._offset.y = 0, 0 return end
    s.elapsed = s.elapsed + dt
    if s.elapsed >= s.duration then
        self._shake = { magnitude = 0, duration = 0, elapsed = 0 }
        self._offset.x, self._offset.y = 0, 0
        return
    end
    local remaining = 1 - s.elapsed / s.duration
    local amp = s.magnitude * remaining
    self._offset.x = (love.math.random() * 2 - 1) * amp
    self._offset.y = (love.math.random() * 2 - 1) * amp
end

function Camera:update(dt)
    if self.following then
        local tx = self.following.x or self.following[1]
        local ty = self.following.y or self.following[2]
        if tx and ty then
            local k = 1 - math.exp(-self.followLerp * dt)
            self.x = self.x + (tx - self.x) * k
            self.y = self.y + (ty - self.y) * k
        end
    end
    self:_applyShake(dt)
end

function Camera:attach()
    if not love or not love.graphics then return end
    local w, h = love.graphics.getDimensions()
    love.graphics.push()
    love.graphics.translate(w / 2 + self._offset.x, h / 2 + self._offset.y)
    love.graphics.rotate(self.rotation)
    love.graphics.scale(self._zoom, self._zoom)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
    if not love or not love.graphics then return end
    love.graphics.pop()
end

function Camera:worldToScreen(wx, wy)
    local w, h = love.graphics.getDimensions()
    return w / 2 + (wx - self.x) * self._zoom, h / 2 + (wy - self.y) * self._zoom
end

function Camera:screenToWorld(sx, sy)
    local w, h = love.graphics.getDimensions()
    return self.x + (sx - w / 2) / self._zoom, self.y + (sy - h / 2) / self._zoom
end

return Camera
