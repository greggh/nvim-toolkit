# Getting Started

This guide will help you get started with nvim-toolkit.

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

### Using Git Submodule

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

## Basic Configuration

After installing nvim-toolkit, you can configure it in your Neovim configuration:

```lua
-- Require the main module
local toolkit = require('nvim_toolkit')

-- Setup with default options
toolkit.setup()

-- Or with custom options
toolkit.setup({
  log = {
    level = "info",                                       -- Log level (debug, info, warn, error)
    file = vim.fn.stdpath("cache") .. "/logs/myapp.log", -- Log file path
    use_colors = true                                     -- Use colors in console output
  },
  ui = {
    float = {
      border = "rounded", -- Window border style
      width = 80,         -- Default width
      height = 20         -- Default height
    }
  },
  fs = {
    cache_timeout = 60 -- Cache timeout in seconds
  }
})
```

## Using Modules Independently

You can use each module independently:

```lua
-- Use the logging module
local log = require('nvim_toolkit.log')
log.info("Application started")
log.debug("Debug information", { details = "More info" })

-- Use the UI module
local ui = require('nvim_toolkit.ui')
local win, buf = ui.float.open({
  title = "My Window",
  content = {"Line 1", "Line 2"},
})

-- Use the filesystem module
local fs = require('nvim_toolkit.fs')
local root = fs.find_root()
local file_content = fs.read_file("/path/to/file")

-- Use the API wrappers
local api = require('nvim_toolkit.api')
api.create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function() print("Saving Lua file") end
})

-- Use the config module
local config = require('nvim_toolkit.config')
local validated = config.validate(user_config, schema)

-- Use the keymap module
local keymap = require('nvim_toolkit.keymap')
keymap.register_group("<leader>f", {
  f = keymap.bind.map_cr("Telescope find_files"):with_desc("Find files"):with_common_options(),
})
```

See the [Examples](./examples.md) page for more detailed usage examples.