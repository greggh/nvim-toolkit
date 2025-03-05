--- Keymap helper utilities for keymapping management
---@module 'nvim_toolkit.keymap.helpers'

local M = {}

-- Module configuration (will be updated by setup)
local config = {
  which_key_integration = true,
  which_key_defer_time = 50,
  icons = {},
}

--- Setup the helpers module with configuration
---@param cfg table Configuration table
function M.setup(cfg)
  config = vim.tbl_deep_extend("force", config, cfg or {})
end

-- Check which-key availability directly where needed

--- Register keymaps with which-key if it's available
---@param prefix string The keymap prefix
---@param mappings table Mapping definitions
---@param icon string|nil Icon to use for the mapping group
local function register_with_which_key(prefix, mappings, icon)
  -- Skip if which-key integration is disabled
  if not config.which_key_integration then
    return false
  end

  -- Try to load which-key
  vim.defer_fn(function()
    local status_ok, which_key = pcall(require, "which-key")
    if not status_ok then
      return
    end

    -- Extract mode from prefix if it includes |
    local mode, actual_prefix = "n", prefix
    if prefix:find("|") then
      local parts = vim.split(prefix, "|")
      mode, actual_prefix = parts[1], parts[2]
    end

    -- Convert mappings to which-key format
    local which_key_mappings = {}
    for key, map_def in pairs(mappings) do
      if type(map_def) == "table" and map_def.options and map_def.options.desc then
        which_key_mappings[key] = {
          map_def.options.desc,
          icon = icon or config.icons.default,
        }
      end
    end

    -- Register with which-key
    if vim.tbl_count(which_key_mappings) > 0 then
      which_key.register({ [actual_prefix] = which_key_mappings }, { mode = mode })
    end
  end, config.which_key_defer_time)

  return true
end

--- Register a group of keymaps with a common prefix
---@param prefix string Keymap prefix
---@param keymaps table Key-value mapping of keymaps
---@param icon string|nil Icon to use for the group
---@param defer boolean|nil Whether to defer loading
function M.register_keymap_group(prefix, keymaps, icon, defer)
  local log = require("nvim_toolkit.log")
  local bind = require("nvim_toolkit.keymap.bind")

  -- Process keymaps to ensure they have the prefix
  local processed_keymaps = {}

  -- Determine mode from prefix
  local mode, actual_prefix = "n", prefix
  if prefix:find("|") then
    local parts = vim.split(prefix, "|")
    mode, actual_prefix = parts[1], parts[2]
  end

  log.debug("Registering keymap group with prefix: " .. prefix)

  -- Convert keymaps to the expected format
  for key, map_def in pairs(keymaps) do
    local full_key
    if key:find("|") then
      -- Key already has mode, keep as is
      full_key = key
    else
      -- Add mode to key
      full_key = mode .. "|" .. actual_prefix .. key
    end

    if type(map_def) == "table" then
      -- Copy mapdef as is
      processed_keymaps[full_key] = map_def
    else
      -- Convert string descriptions to map_cmd
      processed_keymaps[full_key] = bind.map_cmd(map_def):with_desc(map_def):with_common_options()
    end
  end

  -- Register with which-key if possible
  register_with_which_key(prefix, processed_keymaps, icon)

  -- Load the mappings
  bind.nvim_load_mapping(processed_keymaps, defer)
end

--- Setup special keymaps for terminal buffers
---@param buf number Buffer number
---@param keymaps table Terminal keymaps
function M.setup_terminal_keymaps(buf, keymaps)
  local log = require("nvim_toolkit.log")

  if not vim.api.nvim_buf_is_valid(buf) then
    log.error("Invalid buffer for terminal keymaps: " .. tostring(buf))
    return
  end

  -- Setup defaults for terminal navigation
  if keymaps.window_navigation then
    -- Window navigation keymaps for terminal mode need special handling
    vim.api.nvim_buf_set_keymap(
      buf,
      "t",
      "<C-h>",
      [[<C-\><C-n><C-w>h]],
      { noremap = true, silent = true, desc = "Window: move left" }
    )
    vim.api.nvim_buf_set_keymap(
      buf,
      "t",
      "<C-j>",
      [[<C-\><C-n><C-w>j]],
      { noremap = true, silent = true, desc = "Window: move down" }
    )
    vim.api.nvim_buf_set_keymap(
      buf,
      "t",
      "<C-k>",
      [[<C-\><C-n><C-w>k]],
      { noremap = true, silent = true, desc = "Window: move up" }
    )
    vim.api.nvim_buf_set_keymap(
      buf,
      "t",
      "<C-l>",
      [[<C-\><C-n><C-w>l]],
      { noremap = true, silent = true, desc = "Window: move right" }
    )
  end

  -- Setup custom keymaps
  for key, mapping in pairs(keymaps.custom or {}) do
    if type(mapping) == "table" then
      vim.api.nvim_buf_set_keymap(buf, "t", key, mapping.cmd, {
        noremap = mapping.noremap ~= false,
        silent = mapping.silent ~= false,
        desc = mapping.desc or "",
      })
    else
      -- Simple string command
      vim.api.nvim_buf_set_keymap(buf, "t", key, mapping, { noremap = true, silent = true })
    end
  end

  log.debug("Set up terminal keymaps for buffer: " .. tostring(buf))
end

--- Create toggle keymaps for a feature
---@param name string Feature name
---@param toggle_func function Toggle function
---@param keys table Key mappings
---@param desc string|nil Description
function M.create_toggle_keymaps(name, toggle_func, keys, desc)
  local log = require("nvim_toolkit.log")
  local bind = require("nvim_toolkit.keymap.bind")

  desc = desc or (name .. ": Toggle")
  local mappings = {}

  -- Set up normal mode toggle
  if keys.normal then
    mappings["n|" .. keys.normal] = bind.map_callback(toggle_func):with_desc(desc):with_common_options()
  end

  -- Set up terminal mode toggle (needs special handling)
  if keys.terminal then
    mappings["t|" .. keys.terminal] =
      bind.map_cmd([[<C-\><C-n>:lua ]] .. toggle_func .. [[()<CR>]]):with_desc(desc):with_common_options()
  end

  -- Set up other modes if specified
  for mode, key in pairs(keys) do
    if mode ~= "normal" and mode ~= "terminal" then
      mappings[mode:sub(1, 1) .. "|" .. key] = bind.map_callback(toggle_func):with_desc(desc):with_common_options()
    end
  end

  log.debug("Created toggle keymaps for " .. name)
  bind.nvim_load_mapping(mappings)

  -- Register with which-key if available
  if config.which_key_integration then
    vim.defer_fn(function()
      local status_ok, which_key = pcall(require, "which-key")
      if status_ok then
        for mode, key in pairs(keys) do
          which_key.register({
            [key] = { desc = desc, icon = config.icons.default },
          }, { mode = mode:sub(1, 1) })
        end
      end
    end, config.which_key_defer_time)
  end

  return mappings
end

return M
