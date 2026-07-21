--[[
    Utils/math.lua — pure math helpers. No LÖVE dependency, easy to test.
]]

local M = {}

function M.clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end
function M.lerp(a, b, t)   return a + (b - a) * t end
function M.inverseLerp(a, b, v)
    if a == b then return 0 end
    return (v - a) / (b - a)
end
function M.remap(v, inA, inB, outA, outB)
    return outA + (outB - outA) * M.inverseLerp(inA, inB, v)
end

function M.distance(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end
function M.distanceSq(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return dx * dx + dy * dy
end
function M.angleTo(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end
function M.approach(cur, target, step)
    if cur < target then return math.min(cur + step, target) end
    if cur > target then return math.max(cur - step, target) end
    return cur
end
function M.sign(v) if v > 0 then return 1 elseif v < 0 then return -1 else return 0 end end
function M.fract(v) return v - math.floor(v) end
function M.step(edge, v) return (v < edge) and 0 or 1 end
function M.smoothstep(edge0, edge1, v)
    local t = M.clamp((v - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)
end

-- Vector-ish helpers (for 2D)
function M.vec2Length(x, y)  return math.sqrt(x * x + y * y) end
function M.vec2Normalize(x, y)
    local l = M.vec2Length(x, y)
    if l == 0 then return 0, 0, 0 end
    return x / l, y / l, l
end
function M.vec2Dot(ax, ay, bx, by) return ax * bx + ay * by end
function M.vec2Rotate(x, y, rad)
    local c, s = math.cos(rad), math.sin(rad)
    return c * x - s * y, s * x + c * y
end

return M
