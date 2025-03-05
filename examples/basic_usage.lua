-- Basic Usage Examples for nvim-toolkit
-- This file demonstrates various features of the toolkit

-- Load the full toolkit
local toolkit = require("nvim_toolkit")

-- Initialize with custom configuration
toolkit.setup({
  log = {
    level = "debug",
    file = vim.fn.stdpath("cache") .. "/logs/example.log",
    use_colors = true,
  },
  ui = {
    float = {
      border = "rounded",
      width = 60,
      height = 10,
    },
  },
  fs = {
    cache_timeout = 60, -- 1 minute cache timeout
  },
})

-- Example 1: Logging
local log = require("nvim_toolkit.log")
log.debug("This is a debug message")
log.info("Application started", { user = "example" })
log.warn("This is a warning")
log.error("This is an error", { code = 500 })

-- Example 2: UI Float windows
local ui = require("nvim_toolkit.ui")
-- Use _G to store the window ID so it's accessible in the keymap
_G._example_win_id = nil
local float_win, float_buf = ui.float.open({
  title = "Example Window",
  content = {
    "This is a floating window example",
    "",
    "Press q to close",
  },
  on_open = function(win_id, _)
    _G._example_win_id = win_id
  end,
  keymaps = {
    n = {
      q = { "<cmd>lua require('nvim_toolkit.ui').float.close(_G._example_win_id)<CR>", "Close window" },
    },
  },
})

-- Use them to avoid unused variable warnings
if float_win and float_buf then
  print(string.format("Created window %d with buffer %d", float_win, float_buf))
end

-- Example 3: Notifications
ui.notify.info("This is an info notification")
ui.notify.warn("This is a warning notification", {
  timeout = 5000, -- 5 seconds
})
ui.notify.error("This is an error notification", {
  title = "Error Occurred",
})

-- Example 4: Filesystem utilities
local fs = require("nvim_toolkit.fs")
local project_root = fs.find_root()
if project_root then
  log.info("Project root detected: " .. project_root)
end

-- Check if a file exists
if fs.file_exists(vim.fn.expand("~/.config/nvim/init.lua")) then
  log.info("Neovim config exists")
end

-- Example 5: Safe API calls
local api = require("nvim_toolkit.api")
api.create_augroup("NvimToolkitExample", true)
api.create_autocmd("BufWritePost", {
  group = "NvimToolkitExample",
  pattern = "*.lua",
  callback = function()
    log.info("Lua file saved", { file = vim.fn.expand("%:p") })
  end,
})

-- Example 6: Configuration validation
local config = require("nvim_toolkit.config")
local user_config = {
  window_size = 100,
  format = "json",
  retry = true,
}

local schema = {
  window_size = {
    type = "number",
    min = 10,
    max = 200,
    default = 80,
  },
  format = {
    type = "string",
    enum = { "json", "yaml", "toml" },
    default = "json",
  },
  retry = {
    type = "boolean",
    default = false,
  },
  timeout = {
    type = "number",
    default = 1000,
  },
}

local validated = config.validate(user_config, schema)
log.info("Validated config", validated)
