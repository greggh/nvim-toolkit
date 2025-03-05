--- Keymap binding utilities with method chaining
---@module 'nvim_toolkit.keymap.bind'

---@class map_rhs
---@field cmd string The command to execute when the keymap is triggered
---@field options table Options for the keymap
---@field options.noremap boolean Whether the keymap is non-recursive
---@field options.silent boolean Whether the keymap is silent
---@field options.expr boolean Whether the keymap is an expression
---@field options.nowait boolean Whether the keymap should execute immediately
---@field options.callback function Callback function for the keymap
---@field options.desc string Description of the keymap
---@field buffer boolean|number Buffer number for buffer-local keymaps, or false for global
local rhs_options = {}

--- Creates a new keymap options instance
---@return map_rhs New map_rhs instance
function rhs_options:new()
  local instance = {
    cmd = "",
    options = {
      noremap = false,
      silent = false,
      expr = false,
      nowait = false,
      callback = nil,
      desc = "",
    },
    buffer = false,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

--- Maps a command string directly
---@param cmd_string string The command string
---@return map_rhs Self for method chaining
function rhs_options:map_cmd(cmd_string)
  self.cmd = cmd_string
  return self
end

--- Maps a command with a CR appended (for Ex commands)
---@param cmd_string string The command string without CR
---@return map_rhs Self for method chaining
function rhs_options:map_cr(cmd_string)
  self.cmd = (":%s<CR>"):format(cmd_string)
  return self
end

--- Maps a command that will receive arguments (adds a space after)
---@param cmd_string string The command string without the space
---@return map_rhs Self for method chaining
function rhs_options:map_args(cmd_string)
  self.cmd = (":%s<Space>"):format(cmd_string)
  return self
end

--- Maps a command with C-u (for visual mode commands to clear range)
---@param cmd_string string The command string
---@return map_rhs Self for method chaining
function rhs_options:map_cu(cmd_string)
  -- <C-u> to eliminate the automatically inserted range in visual mode
  self.cmd = (":<C-u>%s<CR>"):format(cmd_string)
  return self
end

--- Maps a Lua callback function
---@param callback function The callback function to execute
---@return map_rhs Self for method chaining
function rhs_options:map_callback(callback)
  self.cmd = ""
  self.options.callback = callback
  return self
end

--- Add the silent option to the keymap
---@return map_rhs Self for method chaining
function rhs_options:with_silent()
  self.options.silent = true
  return self
end

--- Add a description to the keymap
---@param description_string string The description
---@return map_rhs Self for method chaining
function rhs_options:with_desc(description_string)
  self.options.desc = description_string
  return self
end

--- Make the keymap non-recursive
---@return map_rhs Self for method chaining
function rhs_options:with_noremap()
  self.options.noremap = true
  return self
end

--- Make the keymap evaluate as an expression
---@return map_rhs Self for method chaining
function rhs_options:with_expr()
  self.options.expr = true
  return self
end

--- Make the keymap execute immediately
---@return map_rhs Self for method chaining
function rhs_options:with_nowait()
  self.options.nowait = true
  return self
end

--- Make the keymap buffer-local
---@param num number Buffer number
---@return map_rhs Self for method chaining
function rhs_options:with_buffer(num)
  self.buffer = num
  return self
end

--- Add common options (noremap and silent)
---@return map_rhs Self for method chaining
function rhs_options:with_common_options()
  self.options.noremap = true
  self.options.silent = true
  return self
end

-- Public API
local bind = {}

--- Create a command with CR mapping
---@param cmd_string string The command
---@return map_rhs The keymap instance
function bind.map_cr(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cr(cmd_string)
end

--- Create a direct command mapping
---@param cmd_string string The command
---@return map_rhs The keymap instance
function bind.map_cmd(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cmd(cmd_string)
end

--- Create a command with C-u mapping
---@param cmd_string string The command
---@return map_rhs The keymap instance
function bind.map_cu(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cu(cmd_string)
end

--- Create a command with arguments mapping
---@param cmd_string string The command
---@return map_rhs The keymap instance
function bind.map_args(cmd_string)
  local ro = rhs_options:new()
  return ro:map_args(cmd_string)
end

--- Create a callback mapping
---@param callback function The callback function
---@return map_rhs The keymap instance
function bind.map_callback(callback)
  local ro = rhs_options:new()
  return ro:map_callback(callback)
end

--- Escape terminal codes in a string
---@param cmd_string string String with terminal codes
---@return string Escaped string
function bind.escape_termcode(cmd_string)
  return vim.api.nvim_replace_termcodes(cmd_string, true, true, true)
end

--- Load a set of mappings
---@param mapping table<string, map_rhs> The mapping table
---@param defer boolean|nil Whether to defer the keymap loading
function bind.nvim_load_mapping(mapping, defer)
  local toolkit_log = require("nvim_toolkit.log")

  -- If defer is true, use defer_fn to load keymaps after a short delay
  if defer then
    toolkit_log.debug("Deferring keymap loading")

    vim.defer_fn(function()
      bind.nvim_load_mapping(mapping, false)
    end, 10) -- Small delay to improve startup time
    return
  end

  -- Create a unique autocommand group for mapping
  local augroup_id =
    vim.api.nvim_create_augroup("NvimToolkitKeymap" .. tostring(math.random(1000000)), { clear = true })

  -- Use autocmd for better organization and to ensure all maps are properly loaded
  vim.api.nvim_create_autocmd("User", {
    pattern = "KeymapsLoading",
    once = true,
    group = augroup_id,
    callback = function()
      toolkit_log.debug("Loading " .. vim.inspect(vim.tbl_count(mapping)) .. " keymaps")

      for key, value in pairs(mapping) do
        if type(value) ~= "table" then
          toolkit_log.warn("Invalid keymap value for " .. key)
          goto continue
        end

        local modes, keymap = key:match("([^|]*)|?(.*)")
        if not modes or not keymap then
          toolkit_log.warn("Invalid keymap format: " .. key)
          goto continue
        end

        local rhs = value.cmd
        local options = value.options
        local buf = value.buffer

        -- Apply the mapping to each mode character
        for i = 1, #modes do
          local mode = modes:sub(i, i)
          local status, err = pcall(function()
            if buf and type(buf) == "number" then
              vim.api.nvim_buf_set_keymap(buf, mode, keymap, rhs, options)
            else
              vim.api.nvim_set_keymap(mode, keymap, rhs, options)
            end
          end)

          if not status then
            toolkit_log.error("Failed to set keymap " .. mode .. keymap .. ": " .. tostring(err))
          end
        end

        ::continue::
      end
    end,
  })

  -- Trigger the autocmd immediately
  vim.api.nvim_exec_autocmds("User", { pattern = "KeymapsLoading" })
end

return bind
