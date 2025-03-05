# Log Module

The log module provides a comprehensive logging system for Neovim plugins.

## Basic Usage

```lua
local log = require('nvim_toolkit.log')

-- Log at different levels
log.debug("Debug message", { details = "some_value" })
log.info("Information message")
log.warn("Warning message")
log.error("Error message", { code = 500 })

-- Configure log level
log.set_level(log.levels.DEBUG) -- Show all messages
log.set_level(log.levels.WARN)  -- Only show warnings and errors
```

## Configuration

You can configure the logging system when initializing the toolkit:

```lua
require('nvim_toolkit').setup({
  log = {
    level = "info",                                       -- Log level (debug, info, warn, error)
    file = vim.fn.stdpath("cache") .. "/logs/myapp.log", -- Log file path
    use_colors = true,                                    -- Use colors in console output
    max_size = 1024 * 1024,                               -- Maximum log file size (1MB)
    use_console = true                                    -- Also output to console
  }
})
```

Or configure it directly:

```lua
local log = require('nvim_toolkit.log')
log.setup({
  level = "debug",
  file = "/path/to/logs/myapp.log"
})
```

## Log Levels

The log module supports the following log levels:

| Level | Description |
|-------|-------------|
| `DEBUG` | Detailed information for debugging |
| `INFO` | General information about normal operation |
| `WARN` | Warnings that don't prevent operation |
| `ERROR` | Errors that may prevent correct operation |

## Additional Features

### Context Information

You can provide additional context with each log message:

```lua
log.info("User performed action", {
  user = "someone",
  action = "save",
  time_taken = 123
})
```

### In-Memory Logging for Tests

For testing, you can switch to in-memory logging:

```lua
log.setup({
  use_memory = true,
  use_file = false,
  use_console = false
})

-- Later, retrieve logged messages
local messages = log.get_memory_log()
assert(#messages > 0, "No messages were logged")
```

### Log File Rotation

The log module automatically rotates log files when they reach the configured `max_size`:

```lua
log.setup({
  file = "/path/to/log.txt",
  max_size = 1024 * 1024, -- 1MB
  backup_count = 3         -- Keep 3 rotated files
})
```