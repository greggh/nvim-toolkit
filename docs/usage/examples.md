# Examples

This page contains examples of how to use nvim-toolkit.

## Basic Example

This example demonstrates how to use the toolkit with default configuration:

```lua
-- Initialize with default settings
local toolkit = require('nvim_toolkit')
toolkit.setup()

-- Log messages
local log = require('nvim_toolkit.log')
log.info("Application started")
log.debug("Here's some debug info")
log.warn("Warning message")
log.error("Error occurred", { code = 500 })

-- Create a floating window
local ui = require('nvim_toolkit.ui')
local win_id, buf_id = ui.float.open({
  title = "Example Window",
  content = {
    "This is a floating window",
    "",
    "Press q to close it"
  },
  keymaps = {
    n = {
      q = { "<cmd>lua vim.api.nvim_win_close(0, true)<CR>", "Close window" }
    }
  }
})
```

## Keymap Example

This example demonstrates the keymap module's fluent API:

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
  r = bind.map_cr("Telescope oldfiles"):with_desc("Recent files"):with_common_options(),
}, "file")

-- Create terminal-specific keymaps
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(args)
    keymap.set_terminal_keymaps(args.buf, {
      window_navigation = true,
      custom = {
        ["<Esc>"] = { cmd = [[<C-\><C-n>]], desc = "Exit terminal mode" }
      }
    })
  end
})
```

## Configuration Validation Example

This example demonstrates how to use the configuration validation system:

```lua
local config = require('nvim_toolkit.config')

-- Define a schema for your configuration
local schema = {
  window_size = {
    type = "number",
    min = 10,
    max = 200,
    default = 80
  },
  format = {
    type = "string",
    enum = {"json", "yaml", "toml"},
    default = "json"
  },
  retry = {
    type = "boolean",
    default = false
  },
  nested = {
    type = "table",
    schema = {
      timeout = {
        type = "number",
        default = 1000
      }
    }
  }
}

-- User configuration
local user_config = {
  window_size = 100,
  format = "json",
  retry = true,
  -- Note: nested.timeout will get default value
}

-- Validate the configuration
local validated = config.validate(user_config, schema)
-- validated now contains the validated config with defaults applied
```

For more detailed examples, see the [example files in the repository](https://github.com/greggh/nvim-toolkit/tree/main/examples).