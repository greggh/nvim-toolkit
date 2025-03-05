--- UI components and helpers
---@module 'nvim_toolkit.ui'

local M = {}

-- Default configuration
local default_config = {
  float = {
    border = "rounded",
    width = 80,
    height = 20,
  },
  notifications = {
    timeout = 3000,
    max_width = 80,
  },
}

-- Module configuration
M.config = vim.deepcopy(default_config)

-- Load UI modules
M.float = require("nvim_toolkit.ui.float")
M.notify = require("nvim_toolkit.ui.notify")

-- Setup function
---@param opts table|nil Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})
  return M
end

-- Expose notification conveniences at the UI module level
M.info = function(message, opts)
  return M.notify.info(message, opts)
end

M.warn = function(message, opts)
  return M.notify.warn(message, opts)
end

M.error = function(message, opts)
  return M.notify.error(message, opts)
end

return M
