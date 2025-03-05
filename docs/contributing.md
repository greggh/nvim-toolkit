# Contributing

Thank you for considering contributing to nvim-toolkit! This document outlines the process for contributing to this project.

## Development Setup

1. Fork the repository on GitHub
2. Clone your fork locally
   ```bash
   git clone https://github.com/YOUR_USERNAME/nvim-toolkit.git
   cd nvim-toolkit
   ```
3. Install development dependencies
   ```bash
   # Install StyLua and Luacheck if you don't have them globally
   luarocks install --local stylua
   luarocks install --local luacheck
   ```
4. Set up pre-commit hooks (recommended)
   ```bash
   ./scripts/install_hooks.sh
   ```

## Development Workflow

1. Create a feature branch
   ```bash
   git checkout -b feature/my-feature
   ```
2. Make your changes
3. Run tests
   ```bash
   make test
   ```
4. Lint your code
   ```bash
   make lint
   ```
5. Commit your changes with a clear commit message
6. Push your branch to your fork
7. Create a Pull Request

## Code Style

We follow these style guidelines:

- Use StyLua for formatting
- Follow the Lua style guide
- Document all public functions with LuaDoc comments
- Write tests for all new functionality

## Adding New Features

When adding a new feature:

1. Add the feature to the appropriate module
2. Add documentation in the module's header
3. Update the README.md if necessary
4. Add examples to the examples directory
5. Update CHANGELOG.md with your changes

## Versioning

We follow [Semantic Versioning](https://semver.org/). To update the version:

1. Run `scripts/version_bump.lua <new_version>`
2. Review the changes
3. Commit with message "Release: Version X.Y.Z"

## Pull Request Process

1. Update the README.md/documentation with details of changes
2. Update CHANGELOG.md with your changes under the Unreleased section
3. Make sure all tests pass
4. The PR will be merged once it receives approval from maintainers

Thank you for your contributions!