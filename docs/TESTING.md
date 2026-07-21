# Testing

The framework includes a tiny test runner and a base `TestCase`
class. No external dependencies, no LÖVE required.

## Running

```bash
lua tests/runner.lua
```

Output:

```
Running tests.test_class ...
Running tests.test_event ...
Running tests.test_math ...

6 passed, 0 failed (0.01s)
```

A non-zero exit code is returned on failure, so this works in CI:

```yaml
- run: lua tests/runner.lua
```

## Verbose

```bash
lua tests/runner.lua -v
```

Prints every test name with a check or cross on success/failure.

## Filtering

```bash
lua tests/runner.lua test_class
```

Runs only `tests/test_class.lua`.

## Writing a test

```bash
lua artisan.lua make:test test_input
```

Open `tests/test_input.lua`:

```lua
local Test  = require("tests.TestCase")
local Input = require("Services.InputManager")

local TestInput = Test:extend("TestInput")

function TestInput:test_binding_lookups()
    local input = Input:new({ config = { get = function(_, k, d) return d end } })
    -- ... write the assertions
end

return TestInput
```

For tests that need a real `Application`, see below.

## Assertions

| Method                                    | What it checks                                 |
| ----------------------------------------- | ---------------------------------------------- |
| `assertTrue(cond, msg?)`                  | value is exactly `true`                        |
| `assertFalse(cond, msg?)`                 | value is exactly `false`                       |
| `assertNil(v, msg?)`                      | value is `nil`                                 |
| `assertNotNil(v, msg?)`                   | value is not `nil`                             |
| `assertEquals(actual, expected, msg?)`    | strict equality (`==`)                         |
| `assertNotEquals(actual, unexpected)`     | strict inequality                              |
| `assertDeepEquals(actual, expected)`      | recursive table equality                       |
| `assertApprox(actual, expected, eps?)`    | numeric within epsilon (default 1e-6)          |
| `assertError(fn, msg?)`                   | function throws                                 |
| `assertNoError(fn, msg?)`                 | function doesn't throw                         |
| `assertMatch(s, pattern, msg?)`           | string contains a pattern                      |

## setUp / tearDown

Override these on your TestCase subclass to run logic before and
after each test:

```lua
function MyTest:setUp()
    self.app = Application:new()
    self.app:boot()
end

function MyTest:tearDown()
    self.app = nil
end
```

## Tests that need the framework

`Services/InputManager`, `Application`, etc. expect an `app` argument.
For full-stack tests, use:

```lua
local Application = require("core.Application")

function MyTest:setUp()
    self.app = Application:new()
    self.app:boot()
end
```

If a test only needs the input manager, you can construct it directly
with a stub:

```lua
local Input = require("Services.InputManager")
local stubApp = {
    logger = { warn = function() end, error = function() end },
    config = { get = function(_, _, d) return d end },
}
local input = Input:new(stubApp)
```
