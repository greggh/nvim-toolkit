<div align="center">

# Nvim-Toolkit

[![GitHub License](https://img.shields.io/github/license/greggh/nvim-toolkit?style=flat-square)](https://github.com/greggh/nvim-toolkit/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/greggh/nvim-toolkit?style=flat-square)](https://github.com/greggh/nvim-toolkit/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/greggh/nvim-toolkit?style=flat-square)](https://github.com/greggh/nvim-toolkit/issues)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/greggh/nvim-toolkit?style=flat-square)](https://github.com/greggh/nvim-toolkit/commits/main)
[![CI](https://img.shields.io/github/actions/workflow/status/greggh/nvim-toolkit/ci.yml?branch=main&style=flat-square&logo=github)](https://github.com/greggh/nvim-toolkit/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/Version-0.1.0-blue?style=flat-square)](https://github.com/greggh/nvim-toolkit/releases/tag/v0.1.0)
[![Discussions](https://img.shields.io/github/discussions/greggh/nvim-toolkit?style=flat-square&logo=github)](https://github.com/greggh/nvim-toolkit/discussions)
[![Neovim](https://img.shields.io/badge/Neovim-0.8.0+-blueviolet.svg?style=flat-square&logo=neovim)](https://neovim.io)

*Shared runtime utilities library for Neovim plugins and configurations. Provides commonly needed functionality like logging, UI components, filesystem operations, API wrappers, and configuration management for Neovim plugin development.*

[Features](#features) •
[Installation](#installation) •
[Usage](#usage) •
[API Documentation](#api-documentation) •
[Requirements](#requirements) •
[Contributing](#contributing) •
[License](#license) •
[Discussions](https://github.com/greggh/nvim-toolkit/discussions)

</div>

## Features

- 🪟 **UI Components** - Floating windows, status line helpers, notifications, input forms
- 📝 **Logging System** - Multiple log levels, file rotation, configurable formats
- 📂 **Filesystem Utilities** - Path handling, file operations, project root detection
- 🔌 **API Wrappers** - Simplified autocmd creation, buffer/window management
- ⚙️ **Configuration** - Settings management, validation, defaults with overrides
- ⌨️ **Keymap Management** - Fluent API for keymappings, which-key integration, terminal-mode handling

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {'greggh/nvim-toolkit'}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'greggh/nvim-toolkit',
  lazy = true
}
```

## Usage

```lua
-- Basic usage
local toolkit = require('nvim_toolkit')

-- Initialize with default options
toolkit.setup()

-- Or with custom options
toolkit.setup({
  log = {
    level = "debug",
    file = vim.fn.stdpath("cache") .. "/logs/myapp.log"
  },
  ui = {
    float = {
      border = "single"
    }
  }
})

-- Use individual modules
local log = require('nvim_toolkit.log')
log.info("Application started")

local ui = require('nvim_toolkit.ui')
-- Create floating window, etc.
```

## API Documentation

### UI Module

```lua
local ui = require('nvim_toolkit.ui')

-- Create a floating window
local win_id, buf_id = ui.float.open({
  title = "My Window",
  content = {"Line 1", "Line 2"},
  -- options match vim.api.nvim_open_win
})

-- Show notification
ui.notify("Operation completed", "info", {
  timeout = 5000  -- milliseconds
})
```

### Log Module

```lua
local log = require('nvim_toolkit.log')

-- Set log level
log.set_level(log.levels.DEBUG)

-- Log messages
log.debug("Debug message")
log.info("Info message")
log.warn("Warning message")
log.error("Error message")

-- Log with context
log.info("User action", { user = "greggh", action = "save" })
```

### Filesystem Module

```lua
local fs = require('nvim_toolkit.fs')

-- Get project root
local root = fs.find_root()

-- Check if file exists
if fs.file_exists("/path/to/file") then
  -- do something
end

-- Read file content
local content = fs.read_file("/path/to/file")
```

### API Module

```lua
local api = require('nvim_toolkit.api')

-- Create an autocommand
api.create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function() 
    print("Saving Lua file")
  end
})

-- Safe buffer operations
api.set_buffer_lines(buf_id, 0, -1, false, {"New content"})
```

### Config Module

```lua
local config = require('nvim_toolkit.config')

-- Validate user config
local validated = config.validate(user_config, {
  log_level = { type = "string", optional = true },
  timeout = { type = "number", default = 5000 }
})
```

### Keymap Module

```lua
local keymap = require('nvim_toolkit.keymap')
local bind = keymap.bind

-- Create mappings with the fluent API
local my_mapping = bind.map_cr("echo 'Hello'")
  :with_desc("Say hello")
  :with_noremap()
  :with_silent()

-- Register mappings with a common prefix
keymap.register_group("<leader>f", {
  f = bind.map_cr("Telescope find_files"):with_desc("Find files"):with_common_options(),
  g = bind.map_cr("Telescope live_grep"):with_desc("Grep files"):with_common_options(),
}, "file")

-- Set up terminal-specific keymaps
keymap.set_terminal_keymaps(buf, {
  window_navigation = true,
  custom = {
    ["<Esc>"] = { cmd = [[<C-\><C-n>]], desc = "Exit terminal mode" }
  }
})
```

## Installation as Git Submodule

For Neovim plugin projects, you may want to include nvim-toolkit as a git submodule:

```bash
git submodule add https://github.com/greggh/nvim-toolkit external/nvim-toolkit
```

Then in your Lua code:

```lua
-- Add the submodule to package.path
local path_sep = vim.loop.os_uname().sysname:match("Windows") and "\\" or "/"
vim.opt.runtimepath:append(vim.fn.fnamemodify("external/nvim-toolkit", ":p"))

-- Now you can require it
local toolkit = require('nvim_toolkit')
```

## Requirements

- Neovim >= 0.8.0

## Project Structure

```
nvim-toolkit/
├── lua/
│   └── nvim_toolkit/
│       ├── ui/        # UI components and helpers
│       ├── log/       # Logging utilities
│       ├── fs/        # Filesystem utilities
│       ├── api/       # Neovim API wrappers
│       ├── config/    # Configuration utilities
│       └── keymap/    # Keymap management utilities
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is available under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Neovim](https://neovim.io/) - The extensible Vim-based text editor
- [Semantic Versioning](https://semver.org/) - Versioning guidelines
- [Keep a Changelog](https://keepachangelog.com/) - Guidelines for maintaining a changelog

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/greggh">greggh</a></p>
</div>