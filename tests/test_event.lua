-- tests/test_event.lua — smoke tests for core.Event.
local Test = require("tests.TestCase")
local Event = require("core.Event")

local TestEvent = Test:extend("TestEvent")

function TestEvent:test_on_and_emit()
    local e = Event:new()
    local seen = 0
    e:on("ping", function() seen = seen + 1 end)
    e:emit("ping")
    e:emit("ping")
    self:assertEquals(seen, 2)
end

function TestEvent:test_off_removes_handler()
    local e = Event:new()
    local seen = 0
    local fn = function() seen = seen + 1 end
    e:on("ping", fn)
    e:off("ping", fn)
    e:emit("ping")
    self:assertEquals(seen, 0)
end

function TestEvent:test_once_fires_only_one_time()
    local e = Event:new()
    local seen = 0
    e:once("ready", function() seen = seen + 1 end)
    e:emit("ready")
    e:emit("ready")
    e:emit("ready")
    self:assertEquals(seen, 1)
end

function TestEvent:test_filter_blocks_unmatched()
    local e = Event:new()
    local big = 0
    e:on("score", function(amount) big = big + 1 end, function(amount) return amount > 100 end)
    e:emit("score", 10)
    e:emit("score", 50)
    e:emit("score", 200)
    e:emit("score", 500)
    self:assertEquals(big, 2)
end

function TestEvent:test_payload_is_passed_through()
    local e = Event:new()
    local received = nil
    e:on("greet", function(name, age) received = { name = name, age = age } end)
    e:emit("greet", "Ana", 30)
    self:assertEquals(received.name, "Ana")
    self:assertEquals(received.age, 30)
end

function TestEvent:test_wildcard_sees_event_name()
    local e = Event:new()
    local seen = nil
    e:on("*", function(name) seen = name end)
    e:emit("hello")
    self:assertEquals(seen, "hello")
end

return TestEvent
