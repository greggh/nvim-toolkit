--- Neovim API wrappers
---@module 'nvim_toolkit.api'

local M = {}

-- Default configuration
local default_config = {
  safe_mode = true, -- Catch and handle errors in API calls
}

-- Module configuration
M.config = vim.deepcopy(default_config)

-- Load API modules
local autocmd = require("nvim_toolkit.api.autocmd")

-- Export autocmd module functions
M.create_augroup = autocmd.create_augroup
M.create_autocmd = autocmd.create_autocmd
M.delete_autocmd = autocmd.delete_autocmd
M.delete_augroup = autocmd.delete_augroup
M.exec_autocmds = autocmd.exec_autocmds
M.get_augroups = autocmd.get_groups

---Safely call Neovim API functions with error handling
---@param func function Function to call
---@param ... any Arguments to pass to the function
---@return any|nil result Result from the function or nil on error
---@return boolean success True if call was successful
---@return string|nil error Error message if call failed
function M.safe_call(func, ...)
  if not M.config.safe_mode then
    return func(...)
  end

  local status, result = pcall(func, ...)
  if not status then
    require("nvim_toolkit.log").error("API call error: " .. tostring(result), {
      func = tostring(func),
    })
    return nil, false, result
  end

  return result, true, nil
end

---Safely set a buffer option
---@param buffer number Buffer handle
---@param name string Option name
---@param value any Option value
---@return boolean success True if successful
function M.set_buf_option(buffer, name, value)
  local _, success = M.safe_call(vim.api.nvim_buf_set_option, buffer, name, value)
  return success
end

---Safely set buffer lines
---@param buffer number Buffer handle
---@param start_idx number Start line index
---@param end_idx number End line index
---@param strict_indexing boolean Whether to error on out-of-bounds indices
---@param lines table Array of lines to set
---@return boolean success True if successful
function M.set_buffer_lines(buffer, start_idx, end_idx, strict_indexing, lines)
  local _, success = M.safe_call(vim.api.nvim_buf_set_lines, buffer, start_idx, end_idx, strict_indexing, lines)
  return success
end

---Safely check if buffer is valid
---@param buffer number Buffer handle
---@return boolean is_valid True if buffer is valid
function M.is_buf_valid(buffer)
  local result, success = M.safe_call(vim.api.nvim_buf_is_valid, buffer)
  return success and result or false
end

---Safely check if window is valid
---@param window number Window handle
---@return boolean is_valid True if window is valid
function M.is_win_valid(window)
  local result, success = M.safe_call(vim.api.nvim_win_is_valid, window)
  return success and result or false
end

-- Setup function
---@param opts table|nil Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})
  return M
end

return M
