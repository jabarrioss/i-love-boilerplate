--[[
    AudioManager.lua — bus-based sound and music playback.

    Two virtual channels (configurable):
        "sfx"   — short, one-shot sounds (jumps, hits, UI clicks)
        "music" — looping background music (one track at a time)

    Volume and mute state come from config/audio.lua.
    The framework automatically fades music out when switching tracks.
]]

local Class = require("core.Class")

local AudioManager = Class:extend("AudioManager")

function AudioManager:new(app)
    self.app = app
    self._channels = {
        sfx   = { volume = 1.0, sources = {} },
        music = { volume = 1.0, current = nil, target = nil, fadeSpeed = 1.0 },
    }
    self._master = 1.0
    self._muted  = false
    return self
end

function AudioManager:boot()
    local cfg = self.app:config()
    self._master = cfg:get("audio.master", 1.0)
    self._muted  = cfg:get("audio.muted", false)
    for _, ch in pairs({ "sfx", "music" }) do
        self._channels[ch].volume = cfg:get("audio.channels." .. ch, 1.0)
    end
end

function AudioManager:playSound(name, opts)
    if self._muted then return end
    opts = opts or {}
    local src = self.app:assets():get("sound", name)
    if not src then
        self.app:logger():warn("Audio: sound '%s' not loaded", name)
        return
    end
    -- Cloning allows the same source to play multiple times simultaneously.
    local instance = src:clone()
    instance:setVolume((opts.volume or 1.0) * self._channels.sfx.volume * self._master)
    instance:play()
    table.insert(self._channels.sfx.sources, instance)
    return instance
end

function AudioManager:playMusic(name, opts)
    if self._muted then return end
    opts = opts or {}
    local src = self.app:assets():get("music", name)
    if not src then
        self.app:logger():warn("Audio: music '%s' not loaded", name)
        return
    end
    if self._channels.music.current then
        self._channels.music.current:stop()
    end
    self._channels.music.current = src
    src:setLooping(opts.loop ~= false)
    src:setVolume(0)
    src:play()
    -- fade in
    self._channels.music.fadeSpeed = (opts.fadeIn or 1.0) / 1.0
    self._channels.music.target = (opts.volume or 1.0) * self._channels.music.volume * self._master
    return src
end

function AudioManager:stopMusic(fadeOut)
    local ch = self._channels.music
    if not ch.current then return end
    if fadeOut and fadeOut > 0 then
        ch.fadeSpeed = -ch.current:getVolume() / fadeOut
        ch.target = 0
    else
        ch.current:stop()
        ch.current = nil
    end
end

function AudioManager:setMasterVolume(v)
    self._master = math.max(0, math.min(1, v))
    self:_applyVolumes()
end

function AudioManager:setChannelVolume(channel, v)
    if not self._channels[channel] then return end
    self._channels[channel].volume = math.max(0, math.min(1, v))
    self:_applyVolumes()
end

function AudioManager:mute(muted)
    self._muted = muted and true or false
    self:_applyVolumes()
end

function AudioManager:_applyVolumes()
    for ch, data in pairs(self._channels) do
        if ch == "music" and data.current then
            data.current:setVolume(data.target or 0)
        end
    end
end

function AudioManager:update(dt)
    -- Reap finished SFX
    local stillPlaying = {}
    for _, s in ipairs(self._channels.sfx.sources) do
        if s:isPlaying() then table.insert(stillPlaying, s) end
    end
    self._channels.sfx.sources = stillPlaying

    -- Music fade
    local m = self._channels.music
    if m.current and m.target then
        local cur = m.current:getVolume()
        local next = cur + (m.target - cur) * math.min(1, dt * (m.fadeSpeed or 1))
        m.current:setVolume(next)
        if math.abs(m.target - next) < 0.01 then
            m.current:setVolume(m.target)
            if m.target <= 0 then
                m.current:stop()
                m.current = nil
                m.target = nil
            end
        end
    end
end

return AudioManager
