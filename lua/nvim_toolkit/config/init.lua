--- Configuration utilities
---@module 'nvim_toolkit.config'

local M = {}

-- Default configuration
local default_config = {
  validate = true, -- Validate user configurations against schemas
}

-- Module configuration
M.config = vim.deepcopy(default_config)

-- Load config modules
local validate_mod = require("nvim_toolkit.config.validate")

---Validate a configuration object against a schema
---@param config table User configuration to validate
---@param schema table Schema definition for validation
---@param path string|nil Nested path for error messages
---@return table validated Validated and normalized configuration
function M.validate(config, schema, path)
  if not M.config.validate then
    return config
  end

  return validate_mod.validate(config, schema, path)
end

---Create a validator function for reuse
---@param schema table Schema definition
---@return function validator Function that validates configs against the schema
function M.make_validator(schema)
  return function(config, path)
    return M.validate(config, schema, path)
  end
end

-- Configuration schemas for the toolkit itself
M.schemas = {
  -- UI module schema
  ui = {
    float = {
      type = "table",
      default = {},
      schema = {
        border = {
          type = "string",
          enum = { "none", "single", "double", "rounded", "solid", "shadow" },
          default = "rounded",
        },
        width = {
          type = "number",
          min = 1,
          default = 80,
        },
        height = {
          type = "number",
          min = 1,
          default = 20,
        },
      },
    },
    notifications = {
      type = "table",
      default = {},
      schema = {
        timeout = {
          type = "number",
          min = 0,
          default = 3000,
        },
        max_width = {
          type = "number",
          min = 10,
          default = 80,
        },
      },
    },
  },

  -- Log module schema
  log = {
    level = {
      type = "string",
      enum = { "debug", "info", "warn", "error", "off" },
      default = "info",
    },
    file = {
      type = "string",
      optional = true,
      default = nil,
    },
    max_size = {
      type = "number",
      min = 1024,
      default = 1024 * 1024,
    },
    use_console = {
      type = "boolean",
      default = true,
    },
    use_colors = {
      type = "boolean",
      default = true,
    },
  },

  -- FS module schema
  fs = {
    cache_enabled = {
      type = "boolean",
      default = true,
    },
    cache_timeout = {
      type = "number",
      min = 1,
      default = 30,
    },
  },

  -- API module schema
  api = {
    safe_mode = {
      type = "boolean",
      default = true,
    },
  },
}

---Apply toolkit module schemas to validate configuration
---@param module_name string Module name (e.g. 'ui', 'log')
---@param config table Configuration to validate
---@return table validated Validated configuration for the module
function M.apply_schema(module_name, config)
  local schema = M.schemas[module_name]
  if not schema then
    require("nvim_toolkit.log").warn("No schema defined for module: " .. module_name)
    return config or {}
  end

  return M.validate(config, schema, module_name)
end

-- Setup function
---@param opts table|nil Configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})
  return M
end

return M
