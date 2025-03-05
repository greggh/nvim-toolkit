# Nvim-Toolkit

*Shared runtime utilities library for Neovim plugins and configurations*

[![GitHub License](https://img.shields.io/github/license/greggh/nvim-toolkit?style=flat-square)](https://github.com/greggh/nvim-toolkit/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/greggh/nvim-toolkit?style=flat-square)](https://github.com/greggh/nvim-toolkit/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/greggh/nvim-toolkit?style=flat-square)](https://github.com/greggh/nvim-toolkit/issues)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/greggh/nvim-toolkit?style=flat-square)](https://github.com/greggh/nvim-toolkit/commits/main)
[![CI](https://img.shields.io/github/actions/workflow/status/greggh/nvim-toolkit/ci.yml?branch=main&style=flat-square&logo=github)](https://github.com/greggh/nvim-toolkit/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/Version-0.1.0-blue?style=flat-square)](https://github.com/greggh/nvim-toolkit/releases/tag/v0.1.0)
[![Discussions](https://img.shields.io/github/discussions/greggh/nvim-toolkit?style=flat-square&logo=github)](https://github.com/greggh/nvim-toolkit/discussions)

Nvim-Toolkit provides commonly needed functionality for Neovim plugin and configuration development, including:

- **UI Components** – Floating windows, notifications, and UI helpers
- **Logging System** – Multiple log levels, file rotation, configurable formats
- **Filesystem Utilities** – Path handling, file operations, project root detection
- **Neovim API Wrappers** – Simplified autocmd creation, buffer/window management
- **Configuration Utilities** – Settings management, validation, defaults with overrides
- **Keymap Management** – Fluent API for keymappings, which-key integration

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

## Basic Usage

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

## Requirements

- Neovim >= 0.8.0