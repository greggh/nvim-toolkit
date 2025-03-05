-- Example demonstrating the keymap module of nvim-toolkit
-- This file shows how to use the fluent API and keymap organization features

-- Load the toolkit with custom keymap configuration
local toolkit = require("nvim_toolkit")
toolkit.setup({
  keymap = {
    which_key_integration = true,
    icons = {
      default = "󰌌",
      file = "󰈙",
      buffer = "󰈙",
      git = "󰊢",
      window = "󰖲",
    },
  },
})

-- Access the keymap module directly
local keymap = require("nvim_toolkit.keymap")
local bind = keymap.bind

-- Example 1: Basic Keymap Creation
-- This creates a simple keymap using the fluent API
local simple_map = bind.map_cr("echo 'Hello from nvim-toolkit'"):with_desc("Show hello message"):with_common_options()

-- Load a single mapping directly
vim.api.nvim_set_keymap("n", "<leader>h", simple_map.cmd, simple_map.options)

-- Example 2: Create a group of related mappings
local file_mappings = {
  -- Simple key to command mappings
  f = bind.map_cr("Telescope find_files"):with_desc("Find files"):with_common_options(),
  g = bind.map_cr("Telescope live_grep"):with_desc("Grep files"):with_common_options(),
  r = bind.map_cr("Telescope oldfiles"):with_desc("Recent files"):with_common_options(),

  -- Using callback for more complex actions
  n = bind
    .map_callback(function()
      vim.cmd("enew")
      print("Created new file")
    end)
    :with_desc("New file")
    :with_common_options(),

  -- Automatically insert mappings using the bind API
  w = bind.map_cr("write"):with_desc("Save file"):with_common_options(),
  W = bind.map_cr("wall"):with_desc("Save all files"):with_common_options(),
}

-- Register file mappings with which-key under <leader>f prefix
keymap.register_group("<leader>f", file_mappings, "file")

-- Example 3: Terminal-specific mappings
-- Define a callback for terminal setup that would be used in an autocmd
-- This avoids the unused function warning while showing proper usage
vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Setup terminal keymaps from nvim-toolkit demo",
  callback = function(args)
    -- Terminal-specific keymaps with special treatment
    keymap.set_terminal_keymaps(args.buf, {
      -- Enable window navigation from terminal mode
      window_navigation = true,

      -- Custom terminal mappings
      custom = {
        ["<Esc>"] = {
          cmd = [[<C-\><C-n>]],
          desc = "Exit terminal mode",
        },
        ["<leader>tc"] = {
          cmd = [[<C-\><C-n>:bd!<CR>]],
          desc = "Close terminal",
        },
      },
    })
  end,
})

-- Example 4: Toggle functionality with mode-specific keymaps
local function toggle_something()
  print("Feature toggled!")
end

keymap.helpers.create_toggle_keymaps("Feature", toggle_something, {
  normal = "<leader>tf", -- Normal mode binding
  terminal = "<C-t>", -- Terminal mode binding
  visual = "<leader>tf", -- Visual mode binding
}, "Toggle custom feature")

-- Example 5: Loading a full keymap set at once
local all_mappings = {
  -- Format: "{mode}|{keys}" = bind.map_*()...

  -- Normal mode mappings
  ["n|<leader>e"] = bind.map_cr("NvimTreeToggle"):with_desc("Toggle explorer"):with_common_options(),

  -- Multiple modes (normal + visual)
  ["nv|<C-s>"] = bind.map_cr("write"):with_desc("Save file"):with_common_options(),

  -- Insert mode mapping
  ["i|<C-s>"] = bind.map_cmd("<Esc>:write<CR>a"):with_desc("Save file"):with_common_options(),

  -- Buffer-specific mapping (will map to buffer 0)
  ["n|<leader>br"] = bind.map_cr("source %"):with_desc("Reload current buffer"):with_common_options():with_buffer(0),
}

-- Load all mappings at once, deferring non-essential mappings for performance
keymap.load_mappings(all_mappings, true)

-- Inform user
print("Keymap example loaded. Try using <leader>f to access file commands.")
