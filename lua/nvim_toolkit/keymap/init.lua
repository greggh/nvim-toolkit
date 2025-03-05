--- Keymap utilities for Neovim plugin development
---@module 'nvim_toolkit.keymap'

local M = {}

-- Default configuration
local default_config = {
  which_key_integration = true,
  which_key_defer_time = 50,
  mappings_defer_time = 10,
  icons = {
    default = "󰌌",
    file = "󰈙",
    buffer = "󰈙",
    edit = "󰏫",
    window = "󰖲",
    tab = "󰓩",
    terminal = "󰆍",
    search = "󰍉",
    git = "󰊢",
    plugin = "󰏗",
    navigation = "󰜴",
    code = "󱇧",
    ui = "󰕮",
  },
}

-- Module configuration
M.config = vim.deepcopy(default_config)

-- Load submodules
local bind = require("nvim_toolkit.keymap.bind")
local helpers = require("nvim_toolkit.keymap.helpers")

-- Expose keymap binding API
M.bind = bind

-- Helper functions for keymap management
M.helpers = helpers

--- Register mappings with the option to defer loading
---@param mappings table Mapping definitions
---@param defer boolean|nil Whether to defer the mappings loading
function M.load_mappings(mappings, defer)
  bind.nvim_load_mapping(mappings, defer)
end

--- Register a set of keymaps grouped by purpose
---@param group_name string Group name/prefix for which-key
---@param keymaps table Key-value mapping of keymaps
---@param icon string|nil Icon to use for the group
---@param defer boolean|nil Whether to defer loading
function M.register_group(group_name, keymaps, icon, defer)
  helpers.register_keymap_group(group_name, keymaps, icon, defer)
end

--- Register keymaps for terminal buffers with special handling
---@param buf number Buffer number
---@param keymaps table Keymaps to register
function M.set_terminal_keymaps(buf, keymaps)
  helpers.setup_terminal_keymaps(buf, keymaps)
end

--- Setup keymap module
---@param opts table|nil Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})

  -- Initialize submodules
  helpers.setup(M.config)

  return M
end

return M
