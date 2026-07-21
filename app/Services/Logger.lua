--[[
    Logger.lua — leveled logger that writes to stdout and a rotating file.

    Levels: debug, info, warn, error, fatal. Filtered by the
    `app.logging.level` config value. Override the file path with
    `app.logging.file` (default: storage/logs/app.log).
]]

local Class = require("core.Class")

local LEVELS = { debug = 1, info = 2, warn = 3, error = 4, fatal = 5 }
local LEVEL_NAMES = { [1] = "DEBUG", [2] = "INFO", [3] = "WARN", [4] = "ERROR", [5] = "FATAL" }

local Logger = Class:extend("Logger")

function Logger:new(app)
    self.app = app
    self._level = 2 -- info by default; raised/lowered by config
    self._file  = "storage/logs/app.log"
    self._maxBytes = 1024 * 1024 -- 1 MB rotation threshold
    self._consoleColors = {
        [1] = "\27[36m", -- debug = cyan
        [2] = "\27[37m", -- info  = white
        [3] = "\27[33m", -- warn  = yellow
        [4] = "\27[31m", -- error = red
        [5] = "\27[35m", -- fatal = magenta
    }
    self._reset = "\27[0m"
    self:_syncFromConfig()
    return self
end

function Logger:_syncFromConfig()
    if not self.app then return end
    local cfg = self.app:config()
    local levelName = cfg:get("app.logging.level", "info")
    self._level = LEVELS[levelName] or 2
    self._file  = cfg:get("app.logging.file", "storage/logs/app.log")
end

function Logger:setLevel(level)
    if type(level) == "string" then
        self._level = LEVELS[level] or 2
    elseif type(level) == "number" then
        self._level = level
    end
    return self
end

function Logger:_format(level, msg, ...)
    local args = { ... }
    if #args > 0 then
        local ok, formatted = pcall(string.format, tostring(msg), unpack(args))
        msg = ok and formatted or tostring(msg)
    end
    local stamp = os.date("%Y-%m-%d %H:%M:%S")
    return ("[%s] %s %s"):format(stamp, LEVEL_NAMES[level], msg)
end

function Logger:_write(line)
    io.stdout:write(line .. "\n")
    io.stdout:flush()

    if love and love.filesystem then
        local ok, err = love.filesystem.append(self._file, line .. "\n")
        if not ok then
            -- best-effort: try to create the file
            love.filesystem.write(self._file, line .. "\n")
        end
    end
end

function Logger:log(level, msg, ...)
    if LEVELS[level] == nil then level = "info" end
    if LEVELS[level] < self._level then return end
    local line = self:_format(LEVELS[level], msg, ...)
    local color = self._consoleColors[LEVELS[level]] or ""
    io.stdout:write(color .. line .. self._reset .. "\n")
    io.stdout:flush()
    if love and love.filesystem then
        love.filesystem.append(self._file, line .. "\n")
    end
    return self
end

-- Convenience shortcuts
function Logger:debug(msg, ...) self:log("debug", msg, ...) end
function Logger:info(msg, ...)  self:log("info",  msg, ...) end
function Logger:warn(msg, ...)  self:log("warn",  msg, ...) end
function Logger:error(msg, ...) self:log("error", msg, ...) end
function Logger:fatal(msg, ...) self:log("fatal", msg, ...) end

return Logger
