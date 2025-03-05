# Nvim-Toolkit Examples

This directory contains examples demonstrating how to use the nvim-toolkit library in your Neovim plugins or configurations.

## Basic Usage

The `basic_usage.lua` file shows a comprehensive example of using all the major components of the toolkit:

- Logging
- UI components (floating windows, notifications)
- Filesystem utilities
- Neovim API wrappers
- Configuration validation

## How to Run Examples

You can run these examples directly from within Neovim:

```lua
-- From Neovim command line
:luafile /path/to/nvim-toolkit/examples/basic_usage.lua
```

Or load them from your Neovim configuration:

```lua
-- Add to your init.lua
require('/path/to/nvim-toolkit/examples/basic_usage')
```

## Examples Breakdown

### 1. Logging

```lua
local log = require('nvim_toolkit.log')
log.debug("This is a debug message")
log.info("Application started", {user = "example"})
log.warn("This is a warning")
log.error("This is an error", {code = 500})
```

### 2. UI Components

```lua
local ui = require('nvim_toolkit.ui')
local win_id, buf_id = ui.float.open({
  title = "Example Window",
  content = {"Line 1", "Line 2"}
})

ui.notify.info("This is a notification")
```

### 3. Filesystem Utilities

```lua
local fs = require('nvim_toolkit.fs')
local project_root = fs.find_root()
local file_content = fs.read_file(some_path)
```

### 4. API Wrappers

```lua
local api = require('nvim_toolkit.api')
api.create_augroup("MyGroup", true)
api.create_autocmd("BufWritePost", {
  group = "MyGroup",
  pattern = "*.lua",
  callback = function() print("Lua file saved") end
})
```

### 5. Configuration Validation

```lua
local config = require('nvim_toolkit.config')
local validated = config.validate(user_config, schema)
```

## Adding Your Own Examples

If you create interesting examples using nvim-toolkit, feel free to contribute them back to this directory via a pull request!