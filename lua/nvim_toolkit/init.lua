--- nvim-toolkit: Shared runtime utilities for Neovim plugins and configurations
--- Main module that exports all submodules and functionality
---@module 'nvim_toolkit'

local M = {}

-- Version information
local version_module = require("nvim_toolkit.version")
-- Version string is returned directly for backward compatibility
M.version = version_module
-- Standard Lua module version convention
M._VERSION = M.version

-- Set global version for easy access by build scripts
-- Uses the version from version.lua to maintain a single source of truth
_G._NVIM_TOOLKIT_VERSION = M.version

-- Load and expose all submodules
M.ui = require("nvim_toolkit.ui")
M.log = require("nvim_toolkit.log")
M.fs = require("nvim_toolkit.fs")
M.api = require("nvim_toolkit.api")
M.config = require("nvim_toolkit.config")
M.keymap = require("nvim_toolkit.keymap")

-- Setup function for configuring the entire toolkit
---@param opts table|nil Configuration options for all modules
function M.setup(opts)
  opts = opts or {}

  -- Initialize each submodule with its configuration
  M.log.setup(opts.log or {})
  M.ui.setup(opts.ui or {})
  M.fs.setup(opts.fs or {})
  M.api.setup(opts.api or {})
  M.config.setup(opts.config or {})
  M.keymap.setup(opts.keymap or {})

  return M
end

return M
