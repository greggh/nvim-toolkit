--- Logging utilities
---@module 'nvim_toolkit.log'

local M = {}

-- Log levels
M.levels = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
  OFF = 5,
}

-- Level name mapping
local level_names = {
  [M.levels.DEBUG] = "DEBUG",
  [M.levels.INFO] = "INFO",
  [M.levels.WARN] = "WARN",
  [M.levels.ERROR] = "ERROR",
  [M.levels.OFF] = "OFF",
}

-- Default configuration
local default_config = {
  level = M.levels.INFO,
  file = nil, -- Default to no file logging
  max_size = 1024 * 1024, -- 1MB max log file size
  use_console = true,
  use_colors = true,
  timestamp_format = "%Y-%m-%d %H:%M:%S",
}

-- Module configuration
M.config = vim.deepcopy(default_config)

-- Color mappings for different log levels
local colors = {
  [M.levels.DEBUG] = "Comment",
  [M.levels.INFO] = "None",
  [M.levels.WARN] = "WarningMsg",
  [M.levels.ERROR] = "ErrorMsg",
}

-- In-memory log buffer for testing
local memory_log = {}

---Format a log message
---@param level number Log level
---@param message string Message to log
---@param metadata table|nil Optional metadata
---@return string formatted Formatted log message
local function format_message(level, message, metadata)
  -- Format timestamp
  local timestamp = os.date(M.config.timestamp_format)

  -- Format metadata
  local metadata_str = ""
  if metadata then
    local parts = {}
    for k, v in pairs(metadata) do
      table.insert(parts, k .. "=" .. tostring(v))
    end
    if #parts > 0 then
      metadata_str = " [" .. table.concat(parts, ", ") .. "]"
    end
  end

  -- Create formatted message
  return string.format("[%s] [%s]%s %s", timestamp, level_names[level], metadata_str, message)
end

---Append to log file with rotation support
---@param message string Formatted message to append
local function append_to_file(message)
  if not M.config.file then
    return
  end

  -- Get filesystem module
  local fs = require("nvim_toolkit.fs")

  -- Check if file needs rotation
  if fs.file_exists(M.config.file) then
    local stat = vim.loop.fs_stat(M.config.file)
    if stat and stat.size and stat.size > M.config.max_size then
      -- Rotate log file by renaming it with timestamp
      local ts = os.date("%Y%m%d%H%M%S")
      local backup = M.config.file .. "." .. ts
      vim.loop.fs_rename(M.config.file, backup)
    end
  end

  -- Append to file
  local fd = vim.loop.fs_open(M.config.file, "a+", 438)
  if fd then
    vim.loop.fs_write(fd, message .. "\n", -1)
    vim.loop.fs_close(fd)
  end
end

---Output log message to console
---@param level number Log level
---@param message string Formatted message
local function log_to_console(level, message)
  if M.config.use_console then
    if M.config.use_colors and colors[level] and colors[level] ~= "None" then
      vim.api.nvim_echo({ { message, colors[level] } }, false, {})
    else
      vim.api.nvim_echo({ { message } }, false, {})
    end
  end
end

---Add entry to memory log
---@param level number Log level
---@param message string Formatted message
local function log_to_memory(level, message)
  table.insert(memory_log, {
    level = level,
    message = message,
    timestamp = os.time(),
  })

  -- Limit memory log size
  if #memory_log > 1000 then
    table.remove(memory_log, 1)
  end
end

---Log a message at the specified level
---@param level number Log level
---@param message string Message to log
---@param metadata table|nil Optional metadata
local function log(level, message, metadata)
  -- Skip if logging is disabled for this level
  if level < M.config.level then
    return
  end

  -- Format the message
  local formatted = format_message(level, message, metadata)

  -- Log to file if configured
  append_to_file(formatted)

  -- Log to console if enabled
  log_to_console(level, formatted)

  -- Store in memory log
  log_to_memory(level, formatted)
end

---Set the active log level
---@param level number New log level
function M.set_level(level)
  if M.levels[level] then
    M.config.level = M.levels[level]
  elseif type(level) == "number" and level >= 1 and level <= 5 then
    M.config.level = level
  end
end

---Get the memory log entries
---@return table entries Memory log entries
function M.get_memory_log()
  return vim.deepcopy(memory_log)
end

---Clear the memory log
function M.clear_memory_log()
  memory_log = {}
end

-- Create logging functions for each level
M.debug = function(message, metadata)
  log(M.levels.DEBUG, message, metadata)
end

M.info = function(message, metadata)
  log(M.levels.INFO, message, metadata)
end

M.warn = function(message, metadata)
  log(M.levels.WARN, message, metadata)
end

M.error = function(message, metadata)
  log(M.levels.ERROR, message, metadata)
end

-- Setup function
---@param opts table|nil Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})

  -- Log setup info
  M.info("Logger initialized", { level = level_names[M.config.level] })

  return M
end

return M
