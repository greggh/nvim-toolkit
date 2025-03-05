#!/usr/bin/env lua
-- Debug script to check why version.lua isn't being detected

local project_name = "nvim_toolkit"

-- Check if file exists
local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

-- Function to read a file's content
local function read_file(path)
  local file, err = io.open(path, "r")
  if not file then
    return nil, err
  end
  local content = file:read("*a")
  file:close()
  return content
end

-- Debug canonical version file
local version_file_path = string.format("lua/%s/version.lua", project_name)
print("Checking version file: " .. version_file_path)
print("File exists: " .. tostring(file_exists(version_file_path)))

if file_exists(version_file_path) then
  local content = read_file(version_file_path)
  print("File content:\n" .. content)

  local pattern = 'return "([%d%.]+)"'
  local version = content:match(pattern)
  print("Extracted version: " .. tostring(version))
end
