--- Project root detection utilities
---@module 'nvim_toolkit.fs.root'

local uv = vim.loop
local M = {}

-- Default project root markers
local default_root_markers = {
  -- Version control
  ".git",
  ".hg",
  ".svn",

  -- Project configuration
  ".editorconfig",

  -- Language specific
  -- Lua
  ".luarc.json",
  ".luacheckrc",
  "stylua.toml",

  -- JavaScript/TypeScript
  "package.json",
  "tsconfig.json",

  -- Python
  "pyproject.toml",
  "setup.py",
  "setup.cfg",

  -- Rust
  "Cargo.toml",

  -- Neovim specific
  "init.lua",
  "init.vim",
}

---Find project root starting from the given path
---@param start_path string|nil Path to start searching from (defaults to current buffer)
---@param markers table|nil Custom root markers to look for
---@return string|nil Root path if found, nil otherwise
function M.find_root(start_path, markers)
  -- Default to current directory if no start path
  start_path = start_path or vim.fn.expand("%:p:h")
  markers = markers or default_root_markers

  -- Start from the given directory and traverse upward
  local current = start_path

  -- Function to check if path has marker
  local function has_marker(path)
    for _, marker in ipairs(markers) do
      local check = path .. "/" .. marker
      local stat = uv.fs_stat(check)
      if stat then
        return true, path
      end
    end
    return false, nil
  end

  -- Traverse up until root or marker found
  while current and current ~= "" do
    local has_found, root_path = has_marker(current)
    if has_found then
      return root_path
    end

    -- Go up one directory
    local parent = vim.fn.fnamemodify(current, ":h")
    -- Stop if we're already at the top
    if parent == current then
      break
    end
    current = parent
  end

  -- Fallback to current buffer's directory if no root found
  return nil
end

---Gets the project root for the current buffer
---@return string Project root or buffer directory
function M.get_current_root()
  -- Try to find project root
  local root = M.find_root()

  -- Fallback to buffer directory
  if not root then
    root = vim.fn.expand("%:p:h")
  end

  return root
end

---Checks if the given path is inside a project
---@param path string Path to check
---@return boolean true if inside a project
function M.is_in_project(path)
  return M.find_root(path) ~= nil
end

return M
