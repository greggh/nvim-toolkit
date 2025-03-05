# UI Module

The UI module provides components for creating user interfaces in Neovim, including floating windows and notifications.

## Floating Windows

The `float` submodule provides utilities for creating and managing floating windows:

```lua
local ui = require('nvim_toolkit.ui')

-- Create a simple floating window
local win_id, buf_id = ui.float.open({
  title = "My Window",
  content = {"Line 1", "Line 2", "Line 3"},
  width = 60,
  height = 10,
  border = "rounded"
})

-- Close a window
ui.float.close(win_id)

-- Update window content
ui.float.update_content(buf_id, {"New line 1", "New line 2"})

-- Center a window
ui.float.center(win_id)
```

### Float Window Options

The `float.open()` function accepts the following options:

| Option | Type | Description |
|--------|------|-------------|
| `title` | string | Window title |
| `content` | table | Array of strings for the window content |
| `width` | number | Window width (in columns) |
| `height` | number | Window height (in rows) |
| `row` | number | Window position row |
| `col` | number | Window position column |
| `relative` | string | Position relative to ("editor", "win", "cursor") |
| `border` | string | Border style ("none", "single", "double", "rounded", etc.) |
| `filetype` | string | Buffer filetype |
| `keymaps` | table | Keymaps for the window |
| `on_close` | function | Callback when window is closed |

## Notifications

The `notify` submodule provides a simple notification system:

```lua
local ui = require('nvim_toolkit.ui')

-- Show notifications at different levels
ui.notify.info("This is an info notification")
ui.notify.warn("This is a warning", { timeout = 5000 })
ui.notify.error("This is an error", { title = "Error" })
ui.notify.debug("Debug information")

-- Or use the generic notify function
ui.notify("Custom notification", "info", {
  timeout = 3000,
  title = "Custom"
})
```

### Notification Options

The notification functions accept the following options:

| Option | Type | Description |
|--------|------|-------------|
| `timeout` | number | Time in milliseconds before the notification auto-closes |
| `title` | string | Notification title |
| `icon` | string | Icon to display with the notification |
| `position` | string | Where to show the notification ("top", "bottom", etc.) |