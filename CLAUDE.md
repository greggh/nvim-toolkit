# Project: nvim-toolkit

## Overview
Nvim-Toolkit is a shared runtime utilities library for Neovim plugins and configurations. It provides a comprehensive set of modules for common Neovim plugin development needs including UI components, logging, filesystem operations, API wrappers, configuration validation, and keymap management.

## Essential Commands
- Run Tests: `env -C /home/gregg/Projects/neovim/nvim-toolkit lua tests/run_tests.lua`
- Check Formatting: `env -C /home/gregg/Projects/neovim/nvim-toolkit stylua lua/ -c`
- Format Code: `env -C /home/gregg/Projects/neovim/nvim-toolkit stylua lua/`
- Run Linter: `env -C /home/gregg/Projects/neovim/nvim-toolkit luacheck lua/`
- Build Documentation: `env -C /home/gregg/Projects/neovim/nvim-toolkit mkdocs build`

## Project Structure
- `/lua/nvim-toolkit`: Main module directory
- `/lua/nvim-toolkit/ui`: UI components and windows
- `/lua/nvim-toolkit/log`: Logging system
- `/lua/nvim-toolkit/fs`: Filesystem utilities
- `/lua/nvim-toolkit/api`: Neovim API wrappers
- `/lua/nvim-toolkit/config`: Configuration validation
- `/lua/nvim-toolkit/keymap`: Keymap management
- `/examples`: Example scripts demonstrating usage
- `/tests`: Test files for each module

## Current Focus
- Integrating nvim-toolkit into Laravel Helper and Claude Code plugins
- Expanding module functionality based on real-world usage
- Enhancing documentation with more detailed examples
- Implementing test coverage for all modules

## Documentation Links
- Tasks: `/home/gregg/Projects/docs-projects/neovim-ecosystem-docs/tasks/nvim-toolkit-tasks.md`
- Project Status: `/home/gregg/Projects/docs-projects/neovim-ecosystem-docs/project-status.md`
- Architecture: `/home/gregg/Projects/docs-projects/neovim-ecosystem-docs/specs/nvim-toolkit-architecture.md`