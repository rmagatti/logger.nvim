# 🌟 Logger.nvim

This plugin provides a logger class for logging messages via the `vim.notify` function in Neovim.
It provides consistent logging and uses `vim.inspect` under the hood as well when possible to log tables.
I kept copying this code over in my Neovim plugins, now I can just do:

```lua
use {
    "rmagatti/my-beautiful-plugin",
    requires = { "rmagatti/logger.nvim" }
}
```

## 🚀 Usage

To use the logger class, first require it in your Neovim Lua plugin:

```lua
local Logger = require("logger").new({ log_level = "debug", prefix = "my_prefix" })
```

You can optionally set the `log_level` and `prefix` using the setter functions:

```lua
logger:set_log_level("debug")
logger:set_prefix("my_prefix")
```

Then, you can use the logging methods to log messages:

```lua
logger:debug("debug message")
logger:info("info message")
logger:warn("warning message")
logger:error("error message")
```

e.g
```lua
-- Logging examples
logger:debug("This is a debug message.") -- Logs "my_prefix DEBUG: This is a debug message." as a vim.notify with level DEBUG
logger:info("This is an info message.") -- Logs "my_prefix INFO: This is an info message." as a vim.notify with level INFO
logger:warn("This is a warning message.") -- Logs "my_prefix WARN: This is a warning message." as a vim.notify with level WARN
logger:error("This is an error message.") -- Logs "my_prefix ERROR: This is an error message." as a vim.notify with level ERROR

-- Logging tables
logger:debug("something", { something = "foo", bar = "baz" })

-- output
my_prefix DEBUG: something { something = "foo", bar = "baz" }
```

## 🔌 API

### Constructor

```lua
Logger:new(obj_and_config)
```

Creates a new logger instance with an optional `obj_and_config` table. The table can contain the `log_level` and `prefix` properties to set the default log level and prefix for the logger.

### Setters

```lua
Logger:set_log_level(level)
```

Sets the log level for the logger. `level` can be either a string or number, as described in `:h vim.log.levels`.

```lua
Logger:set_prefix(prefix)
```

Sets the prefix for the logger. The prefix is logged alongside the log level in each message.

### Logging methods

```lua
Logger:debug(...)
```

Logs a debug message. This is the most verbose logging level, and will only log if the log level is set to "debug" or `vim.log.levels.DEBUG`.

```lua
Logger:info(...)
```

Logs an info message. This is the default logging level, and will log if the `log_level` is set to `"info"`, `"debug"`, or `vim.log.levels.DEBUG` or `vim.log.levels.INFO`.

```lua
Logger:warn(...)
```

Logs a warning message. This will log if the `log_level` is set to `"warn"`, `"info"`, `"debug"`, or `vim.log.levels.DEBUG` or `vim.log.levels.INFO` or `vim.log.levels.WARN`.

```lua
Logger:error(...)
```

Logs an error message. This will log if the `log_level` is set to `"error"`, `"warn"`, `"info"`, `"debug"`, or `vim.log.levels.DEBUG` or `vim.log.levels.INFO` or `vim.log.levels.WARN` or `vim.log.levels.ERROR`.

## 📝 Notes

This plugin uses `vim.notify` to log messages, so make sure that you have the necessary Neovim version and configuration to use this function.
