--- Notification system
---@module 'nvim_toolkit.ui.notify'

local M = {}

-- Notification levels
M.levels = {
  INFO = "info",
  WARN = "warn",
  ERROR = "error",
  DEBUG = "debug",
  TRACE = "trace",
}

-- Store for active notifications
local active_notifications = {}

-- Internal counter for notification IDs
local notification_id_counter = 0

---Display a notification message
---@param message string The message to display
---@param level? string The notification level (info, warn, error, debug, trace)
---@param opts? table Additional options for the notification
---@return number notification_id Unique ID for the created notification
function M.notify(message, level, opts)
  opts = opts or {}
  level = level or M.levels.INFO

  -- Get notification config
  local config = require("nvim_toolkit.ui").config.notifications

  -- Generate unique ID
  notification_id_counter = notification_id_counter + 1
  local id = notification_id_counter

  -- Handle timeout
  local timeout = opts.timeout or config.timeout or 3000

  -- If native vim.notify is available in Neovim 0.8+
  if vim.notify and vim.fn.has("nvim-0.8") == 1 then
    -- Convert level string to vim.log.levels equivalent
    local level_map = {
      [M.levels.INFO] = vim.log.levels.INFO,
      [M.levels.WARN] = vim.log.levels.WARN,
      [M.levels.ERROR] = vim.log.levels.ERROR,
      [M.levels.DEBUG] = vim.log.levels.DEBUG,
      [M.levels.TRACE] = vim.log.levels.TRACE,
    }

    -- Use vim's native notification
    local notif_id = vim.notify(message, level_map[level] or vim.log.levels.INFO, {
      title = opts.title,
      timeout = timeout,
    })

    -- Store reference to the notification
    active_notifications[id] = {
      id = id,
      vim_id = notif_id,
      message = message,
      level = level,
      created_at = vim.loop.now(),
    }

    -- Setup auto-dismiss
    if timeout > 0 then
      vim.defer_fn(function()
        M.dismiss(id)
      end, timeout)
    end

    return id
  else
    -- Fallback to floating window notification for older Neovim
    local float = require("nvim_toolkit.ui.float")

    -- Format the notification message
    local formatted = {
      string.format("[%s] %s", level:upper(), opts.title or "Notification"),
      string.rep("─", config.max_width or 50),
      message,
    }

    -- Create a floating window for the notification
    local win, buf = float.open({
      width = math.min(#message + 4, config.max_width or 50),
      height = #formatted,
      border = "rounded",
      content = formatted,
    })

    -- Store reference
    active_notifications[id] = {
      id = id,
      win = win,
      buf = buf,
      message = message,
      level = level,
      created_at = vim.loop.now(),
    }

    -- Setup auto-dismiss
    if timeout > 0 then
      vim.defer_fn(function()
        M.dismiss(id)
      end, timeout)
    end

    return id
  end
end

---Dismiss a notification by ID
---@param id number The notification ID to dismiss
function M.dismiss(id)
  local notification = active_notifications[id]
  if not notification then
    return
  end

  if notification.vim_id and vim.notify_dismiss then
    -- For native Neovim notifications
    vim.notify_dismiss(notification.vim_id)
  elseif notification.win and notification.buf then
    -- For floating window notifications
    local float = require("nvim_toolkit.ui.float")
    float.close(notification.win, true)
  end

  active_notifications[id] = nil
end

---Dismiss all active notifications
function M.dismiss_all()
  for id, _ in pairs(active_notifications) do
    M.dismiss(id)
  end
end

---Update notification content
---@param id number Notification ID
---@param message string New message content
function M.update(id, message)
  local notification = active_notifications[id]
  if not notification then
    return
  end

  if notification.vim_id and vim.notify then
    -- Re-notify with same level but new message
    vim.notify(message, notification.level, {
      replace = notification.vim_id,
    })
    notification.message = message
  elseif notification.win and notification.buf then
    -- Update floating window
    local formatted = {
      string.format("[%s] Notification", notification.level:upper()),
      string.rep("─", 50),
      message,
    }
    require("nvim_toolkit.ui.float").update_content(notification.buf, formatted)
    notification.message = message
  end
end

-- Add convenience methods for each notification level
for name, level in pairs(M.levels) do
  M[string.lower(name)] = function(message, opts)
    return M.notify(message, level, opts)
  end
end

return M
