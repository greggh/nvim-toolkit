-- plugin/nvim-toolkit.lua
-- Plugin loader for nvim-toolkit shared utilities library

-- Define plugin requirements
if vim.fn.has("nvim-0.8") == 0 then
  vim.notify("nvim-toolkit requires Neovim >= 0.8", vim.log.levels.ERROR)
  return
end

-- Don't create user commands - this is a library, not an end-user plugin
-- The toolkit can be accessed through:
-- require("nvim_toolkit")

-- No auto-setup for lazy loading - libraries should be explicitly initialized
-- by the plugins that use them
