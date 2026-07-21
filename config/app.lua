-- config/app.lua — framework/runtime settings.
return {
    name     = "i-love-boilerplate",
    version  = "0.1.0",

    logging = {
        level = "info",        -- "debug" | "info" | "warn" | "error" | "fatal"
        file  = "storage/logs/app.log",
    },

    save = {
        slot  = "default",     -- auto-loaded on boot
    },

    random = {
        -- nil or os.time() — leave nil for unpredictable runs in production.
        seed  = nil,
    },
}
