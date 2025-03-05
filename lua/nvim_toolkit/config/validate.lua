--- Configuration validation utilities
---@module 'nvim_toolkit.config.validate'

local M = {}

-- Type checking functions
local type_checkers = {
  string = function(value)
    return type(value) == "string", "expected string, got " .. type(value)
  end,

  number = function(value)
    return type(value) == "number", "expected number, got " .. type(value)
  end,

  boolean = function(value)
    return type(value) == "boolean", "expected boolean, got " .. type(value)
  end,

  table = function(value)
    return type(value) == "table", "expected table, got " .. type(value)
  end,

  array = function(value)
    if type(value) ~= "table" then
      return false, "expected array (table), got " .. type(value)
    end

    -- Check if all keys are numeric and sequential
    local count = 0
    for _ in pairs(value) do
      count = count + 1
    end

    return count == #value, "expected array, got non-sequential table"
  end,

  ["function"] = function(value)
    return type(value) == "function", "expected function, got " .. type(value)
  end,

  callable = function(value)
    local is_func = type(value) == "function"
    local is_callable_table = type(value) == "table" and getmetatable(value) and getmetatable(value).__call

    return is_func or is_callable_table, "expected callable (function or table with __call), got " .. type(value)
  end,
}

---Validate a user configuration against a schema
---@param config table User configuration to validate
---@param schema table Schema definition
---@param path string|nil Nested path for error messages
---@return table validated Validated and normalized configuration
function M.validate(config, schema, path)
  if type(config) ~= "table" then
    config = {}
  end

  path = path or ""
  local result = {}
  local log = require("nvim_toolkit.log")

  for key, definition in pairs(schema) do
    local full_key = path ~= "" and (path .. "." .. key) or key
    local value = config[key]

    -- Handle missing value
    if value == nil then
      if definition.required then
        log.error("Missing required config option: " .. full_key)
        error("Missing required config option: " .. full_key)
      end

      if definition.default ~= nil then
        result[key] = definition.default
      end

      goto continue
    end

    -- Type checking
    if definition.type then
      local checker = type_checkers[definition.type]
      if not checker then
        log.error("Unknown type in validation schema: " .. definition.type)
        error("Unknown type in validation schema: " .. definition.type)
      end

      local is_valid, err_msg = checker(value)
      if not is_valid then
        local error_msg = "Invalid config for " .. full_key .. ": " .. err_msg

        if definition.required then
          log.error(error_msg)
          error(error_msg)
        else
          log.warn(error_msg .. " (using default)")
          result[key] = definition.default
          goto continue
        end
      end
    end

    -- Value validation for enums
    if definition.enum and not vim.tbl_contains(definition.enum, value) then
      local error_msg = "Invalid value for "
        .. full_key
        .. ": expected one of ["
        .. table.concat(definition.enum, ", ")
        .. "], got "
        .. tostring(value)

      if definition.required then
        log.error(error_msg)
        error(error_msg)
      else
        log.warn(error_msg .. " (using default)")
        result[key] = definition.default
        goto continue
      end
    end

    -- Value range validation
    if definition.min and value < definition.min then
      local error_msg = "Value for "
        .. full_key
        .. " is too small: "
        .. tostring(value)
        .. " < "
        .. tostring(definition.min)

      if definition.required then
        log.error(error_msg)
        error(error_msg)
      else
        log.warn(error_msg .. " (using default)")
        result[key] = definition.default
        goto continue
      end
    end

    if definition.max and value > definition.max then
      local error_msg = "Value for "
        .. full_key
        .. " is too large: "
        .. tostring(value)
        .. " > "
        .. tostring(definition.max)

      if definition.required then
        log.error(error_msg)
        error(error_msg)
      else
        log.warn(error_msg .. " (using default)")
        result[key] = definition.default
        goto continue
      end
    end

    -- Custom validator
    if definition.validate and type(definition.validate) == "function" then
      local is_valid, err_msg = definition.validate(value)
      if not is_valid then
        local error_msg = "Invalid config for " .. full_key .. ": " .. (err_msg or "failed validation")

        if definition.required then
          log.error(error_msg)
          error(error_msg)
        else
          log.warn(error_msg .. " (using default)")
          result[key] = definition.default
          goto continue
        end
      end
    end

    -- Nested schema validation
    if definition.schema and type(value) == "table" then
      result[key] = M.validate(value, definition.schema, full_key)
    else
      result[key] = value
    end

    ::continue::
  end

  -- Check for unknown keys
  for k in pairs(config) do
    if not schema[k] then
      log.warn("Unknown config option: " .. (path ~= "" and (path .. "." .. k) or k))
    end
  end

  return result
end

return M
