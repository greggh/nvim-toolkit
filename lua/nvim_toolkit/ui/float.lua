--- Floating window management utilities
---@module 'nvim_toolkit.ui.float'

local M = {}

---Create and open a floating window
---@param opts table Configuration options for the floating window
---@return number, number Window ID and Buffer ID
function M.open(opts)
  opts = opts or {}
  local config = require("nvim_toolkit.ui").config.float

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set content if provided
  if opts.content then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, opts.content)
  end

  -- Default window options
  local win_opts = {
    relative = opts.relative or "editor",
    width = opts.width or config.width,
    height = opts.height or config.height,
    row = opts.row or math.floor((vim.o.lines - (opts.height or config.height)) / 2),
    col = opts.col or math.floor((vim.o.columns - (opts.width or config.width)) / 2),
    style = "minimal",
    border = opts.border or config.border,
    title = opts.title,
    title_pos = opts.title_pos,
  }

  -- Open window
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Set buffer options
  if opts.filetype then
    vim.api.nvim_buf_set_option(buf, "filetype", opts.filetype)
  end

  -- Set local keymaps
  if opts.keymaps then
    for mode, mappings in pairs(opts.keymaps) do
      for key, mapping in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, mode, key, mapping[1], { noremap = true, silent = true, desc = mapping[2] })
      end
    end
  end

  -- Set window-closed callback
  if opts.on_close then
    -- Set autocmd for when window is closed
    local group = vim.api.nvim_create_augroup("nvim_toolkit_float_" .. win, { clear = true })
    vim.api.nvim_create_autocmd("WinClosed", {
      pattern = tostring(win),
      callback = function()
        opts.on_close(win, buf)
      end,
      group = group,
      once = true,
    })
  end

  return win, buf
end

---Close a floating window
---@param win number Window ID
---@param force boolean If true, forces the window to close
function M.close(win, force)
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, force or false)
  end
end

---Update a floating window's content
---@param buf number Buffer ID
---@param content table Array of lines to set
function M.update_content(buf, content)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  end
end

---Center a floating window in the editor
---@param win number Window ID
function M.center(win)
  if vim.api.nvim_win_is_valid(win) then
    local win_config = vim.api.nvim_win_get_config(win)
    local width = win_config.width
    local height = win_config.height

    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    vim.api.nvim_win_set_config(win, {
      relative = "editor",
      row = row,
      col = col,
    })
  end
end

return M
