--- Neovim autocommand API utilities
---@module 'nvim_toolkit.api.autocmd'

local M = {}

-- Store autocommand groups for reference and cleanup
local groups = {}

---Create an autocommand group
---@param name string Group name
---@param clear boolean|nil Clear existing commands in this group
---@return number augroup_id Autogroup ID
function M.create_augroup(name, clear)
  clear = clear == nil and true or clear

  local id = vim.api.nvim_create_augroup(name, { clear = clear })
  groups[name] = id

  return id
end

---Create an autocommand
---@param event string|table Event name or list of event names
---@param opts table Options for the autocommand
---@return number autocmd_id Autocmd ID
function M.create_autocmd(event, opts)
  -- Make a copy of options to avoid modifying the passed table
  local options = vim.deepcopy(opts)

  -- Handle missing pattern
  if not options.pattern then
    options.pattern = "*"
  end

  -- Create group if specified by name but doesn't exist
  if options.group and type(options.group) == "string" and not groups[options.group] then
    options.group = M.create_augroup(options.group, true)
  end

  -- Default to throwing errors when the callback fails
  if options.safe_mode == nil then
    if require("nvim_toolkit.api").config.safe_mode then
      options.safe_mode = true
    end
  end

  -- Add error handling for callbacks if safe_mode is enabled
  if options.safe_mode and options.callback then
    local original_callback = options.callback
    options.callback = function(...)
      local status, result = pcall(original_callback, ...)
      if not status then
        require("nvim_toolkit.log").error("Autocmd error: " .. tostring(result), {
          event = event,
          pattern = options.pattern,
        })
      end
      return status and result or nil
    end
  end

  -- Remove our custom option before passing to Neovim API
  options.safe_mode = nil

  -- Create the autocommand
  return vim.api.nvim_create_autocmd(event, options)
end

---Delete an autocommand by ID
---@param id number Autocmd ID to delete
function M.delete_autocmd(id)
  vim.api.nvim_del_autocmd(id)
end

---Delete an autocommand group by name or ID
---@param group string|number Group name or ID
function M.delete_augroup(group)
  if type(group) == "string" and groups[group] then
    group = groups[group]
  end

  if type(group) == "number" then
    vim.api.nvim_del_augroup_by_id(group)

    -- Find and remove from our tracking table
    for name, id in pairs(groups) do
      if id == group then
        groups[name] = nil
        break
      end
    end
  end
end

---Execute autocmds for an event
---@param event string|table Event name or list of event names
---@param opts table|nil Options for executing autocmds
function M.exec_autocmds(event, opts)
  opts = opts or {}
  vim.api.nvim_exec_autocmds(event, opts)
end

---Get list of all autocmd groups created through this module
---@return table List of group names and IDs
function M.get_groups()
  return vim.deepcopy(groups)
end

return M
