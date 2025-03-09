---Logger class for logging messages via vim.notify and :messages.
---Usage: `local logger = require("logger").new({ log_level = "debug", prefix = "my_prefix" })`
---Optionally set the `log_level` and `prefix` using the setter functions.
---e.g. `logger:set_log_level("debug")` or `logger:set_prefix("my_prefix")`
---@class Logger
local Logger = {}

---Function that handles vararg printing, so logs are consistent.
---@vararg any
local function to_print(...)
  local args = { ... }
  if #args == 1 and type(...) == "table" then
    return vim.inspect(...)
  else
    local to_return = ""

    for _, value in ipairs(args) do
      to_return = vim.fn.join({ to_return, vim.inspect(value) }, " ")
    end

    return to_return
  end
end

---Helper function to log both via vim.notify and to :messages
---@param message string The message to log
---@param level number The log level (vim.log.levels)
---@param self Logger The logger instance
local function log_message(message, level, self)
  -- Send to vim.notify for floating notifications
  vim.notify(message, level)

  -- Only echo to :messages if explicitly configured to do so
  if self.echo_messages then
    -- Use a highlight group based on the level
    local hl_group = "Normal"
    if level == vim.log.levels.ERROR then
      hl_group = "ErrorMsg"
    elseif level == vim.log.levels.WARN then
      hl_group = "WarningMsg"
    elseif level == vim.log.levels.INFO then
      hl_group = "None"
    elseif level == vim.log.levels.DEBUG then
      hl_group = "Comment"
    end

    vim.api.nvim_echo({ { message, hl_group } }, true, {})
  end
end

---Constructor for Logger class.
---@param obj_and_config table Table containing the object and configuration for the logger.
function Logger:new(obj_and_config)
  obj_and_config = obj_and_config or {}
  -- Set default log_level
  self.log_level = vim.log.levels.INFO
  -- Default to not echo messages since vim.notify already does that unless it gets overridden by a notifier plugin
  self.echo_messages = false

  self = vim.tbl_deep_extend("force", self, obj_and_config)

  local mt = {}
  mt.__index = function(t, index)
    local value = self[index]
    if type(value) == "function" then
      return function(first_arg, ...)
        -- Handle both syntaxes:
        -- 1. logger.debug(...) - first_arg is not the logger
        -- 2. logger:debug(...) - first_arg is the logger
        if first_arg == t then
          -- Called with colon syntax (logger:debug)
          return value(first_arg, ...)
        else
          -- Called with dot syntax (logger.debug)
          return value(t, first_arg, ...)
        end
      end
    else
      return value
    end
  end

  setmetatable(obj_and_config, mt)
  return obj_and_config
end

---Set the log level for the logger.
---@param level string|number Either a string or number, see `:h vim.log.levels`
function Logger:set_log_level(level)
  self.log_level = level
end

---Set the prefix for the logger.
---the prefix is logged alongside the log_level in each message.
---@param prefix string
function Logger:set_prefix(prefix)
  self.prefix = prefix

  ---Set whether to echo messages to :messages buffer
  ---@param echo boolean
  function Logger:set_echo_messages(echo)
    self.echo_messages = echo
  end
end

---Log a debug message.
---The most amount of logging, logs only if the log_level is set to "debug" or `vim.log.levels.DEBUG`
---@vararg any
function Logger:debug(...)
  if self.log_level == "debug" or self.log_level == vim.log.levels.DEBUG then
    local message = vim.fn.join({ self.prefix .. " " .. "DEBUG:", to_print(...) }, " ")
    log_message(message, vim.log.levels.DEBUG, self)
  end
end

---Log an info message.
---The default level of logging, logs if the `log_level` is set to `"info"`, `"debug"`, or `vim.log.levels.DEBUG` or `vim.log.levels.INFO`
---@vararg any
function Logger:info(...)
  local valid_values = { "info", "debug", vim.log.levels.DEBUG, vim.log.levels.INFO }

  if vim.tbl_contains(valid_values, self.log_level) then
    local message = vim.fn.join({ self.prefix .. " " .. "INFO:", to_print(...) }, " ")
    log_message(message, vim.log.levels.INFO, self)
  end
end

---Log a warning message.
---Logs if the `log_level` is set to `"warn"`, `"info"`, `"debug"`, or `vim.log.levels.DEBUG` or `vim.log.levels.INFO` or `vim.log.levels.WARN`
---@vararg any
function Logger:warn(...)
  local valid_values = { "info", "debug", "warn", vim.log.levels.DEBUG, vim.log.levels.INFO, vim.log.levels.WARN }

  if vim.tbl_contains(valid_values, self.log_level) then
    local message = vim.fn.join({ self.prefix .. " " .. "WARN:", to_print(...) }, " ")
    log_message(message, vim.log.levels.WARN, self)
  end
end

---Log an error message.
---Logs if the `log_level` is set to `"error"`, `"warn"`, `"info"`, `"debug"`, or `vim.log.levels.DEBUG` or `vim.log.levels.INFO` or `vim.log.levels.WARN` or `vim.log.levels.ERROR`
---@vararg any
function Logger:error(...)
  local message = vim.fn.join({ self.prefix .. " " .. "ERROR:", to_print(...) }, " ")
  log_message(message, vim.log.levels.ERROR, self)
end

return Logger
