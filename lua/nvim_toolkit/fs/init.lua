--- Filesystem utilities
---@module 'nvim_toolkit.fs'

local M = {}

-- Default configuration
local default_config = {
  cache_enabled = true,
  cache_timeout = 30, -- seconds
}

-- Module configuration
M.config = vim.deepcopy(default_config)

-- Cache storage for filesystem operations
local cache = {}

-- Load FS modules
local root = require("nvim_toolkit.fs.root")

-- Export the modules
M.find_root = root.find_root
M.get_current_root = root.get_current_root
M.is_in_project = root.is_in_project

---Check if file exists
---@param path string File path to check
---@return boolean exists True if file exists
function M.file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil and stat.type == "file"
end

---Check if directory exists
---@param path string Directory path to check
---@return boolean exists True if directory exists
function M.directory_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil and stat.type == "directory"
end

---Read file content
---@param path string File path to read
---@return string|nil content File content or nil if error
function M.read_file(path)
  if not M.file_exists(path) then
    return nil
  end

  local fd = vim.loop.fs_open(path, "r", 438)
  if not fd then
    return nil
  end

  local stat = vim.loop.fs_fstat(fd)
  if not stat then
    vim.loop.fs_close(fd)
    return nil
  end

  local content = vim.loop.fs_read(fd, stat.size, 0)
  vim.loop.fs_close(fd)

  return content
end

---Write content to file
---@param path string File path to write
---@param content string Content to write
---@return boolean success True if write succeeded
function M.write_file(path, content)
  local fd = vim.loop.fs_open(path, "w", 438)
  if not fd then
    return false
  end

  local success = vim.loop.fs_write(fd, content, 0)
  vim.loop.fs_close(fd)

  return success ~= nil
end

---Get all files in directory recursively
---@param dir string Directory to scan
---@param pattern string|nil Pattern to match (lua pattern)
---@return table files Table of file paths
function M.scan_dir(dir, pattern)
  if M.config.cache_enabled then
    local cache_key = dir .. (pattern or "")
    if cache[cache_key] and cache[cache_key].timestamp + M.config.cache_timeout > os.time() then
      return vim.deepcopy(cache[cache_key].files)
    end
  end

  local files = {}
  local handle = vim.loop.fs_scandir(dir)
  if not handle then
    return files
  end

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end

    local path = dir .. "/" .. name

    if type == "directory" then
      local sub_files = M.scan_dir(path, pattern)
      for _, file in ipairs(sub_files) do
        table.insert(files, file)
      end
    elseif type == "file" then
      if not pattern or name:match(pattern) then
        table.insert(files, path)
      end
    end
  end

  if M.config.cache_enabled then
    local cache_key = dir .. (pattern or "")
    cache[cache_key] = {
      timestamp = os.time(),
      files = vim.deepcopy(files),
    }
  end

  return files
end

-- Setup function
---@param opts table|nil Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})

  -- Clear cache when config changes
  cache = {}

  return M
end

return M
