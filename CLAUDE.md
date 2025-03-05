# Nvim-Toolkit Shared Utilities Library

## Planned Structure

```
nvim-toolkit/
├── lua/
│   └── nvim-toolkit/
│       ├── ui/        # UI components and helpers
│       ├── log/       # Logging utilities
│       ├── fs/        # Filesystem utilities
│       ├── api/       # Neovim API wrappers
│       └── config/    # Configuration utilities
```

## Planned Features

### UI Components
- Floating window management
- Status line components
- Buffer line components
- Notification system
- Input prompts and forms

### Logging System
- Multiple log levels (debug, info, warn, error)
- Log file rotation
- Configurable log formats
- In-memory logging for testing

### Filesystem Utilities
- Path handling with platform compatibility
- File reading/writing with error handling
- Directory scanning and filtering
- Project root detection

### Neovim API Wrappers
- Simplified autocmd creation
- Buffer and window management
- Safely call Neovim APIs with error handling
- Event handling and callback management

### Configuration Utilities
- Simplified settings management
- User configuration validation
- Default settings with overrides
- Configuration file handling

## Git Commands
- `git -C /home/gregg/Projects/neovim/nvim-toolkit add .` - Stage all changes
- `git -C /home/gregg/Projects/neovim/nvim-toolkit commit -m "message"` - Commit changes
- `git -C /home/gregg/Projects/neovim/nvim-toolkit push` - Push changes

## Integration Strategy
- Add as git submodule to template repositories
- Include as dependency in plugin specifications
- Use in both plugin and configuration projects
- Keep backward compatible with Neovim 0.8+