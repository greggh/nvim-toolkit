-- Version module for nvim-toolkit
-- Single source of truth for the project version

-- This file is used by other components like documentation generators,
-- package managers, and release scripts to determine the current version.

-- Should follow semantic versioning: MAJOR.MINOR.PATCH
-- See https://semver.org/ for more details

local M = {}

-- Individual version components
M.major = 0
M.minor = 1
M.patch = 0

-- Combined semantic version
M.string = string.format("%d.%d.%d", M.major, M.minor, M.patch)

-- For compatibility with require('nvim_toolkit.version')
return M.string
