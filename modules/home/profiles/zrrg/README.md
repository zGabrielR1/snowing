# zrrg Home-Manager Profile

## Modularization

All `.nix` files in this directory (except `default.nix`) are automatically imported. To add new configuration modules (e.g., `programs.nix`, `shell.nix`, `devtools.nix`), simply add them here and they will be included automatically.

- Place window manager configs in the `wm/` subdirectory and import them from a module here if needed.

---

# ZRRG Home Manager Profile

This profile integrates the lazuhyprDotfiles with home-manager for a complete desktop environment setup.

## Features

- **Hyprland Window Manager**: Modern Wayland compositor with tiling capabilities
- **Zsh Shell**: Enhanced with syntax highlighting, autosuggestions, and modular configuration
- **Tmux**: Terminal multiplexer with plugin support
- **Neovim/Vim**: Text editors with custom configurations
- **Development Tools**: Git, lazygit, delta, and various CLI utilities
- **System Utilities**: File managers, system monitors, and productivity tools

## Dotfiles Integration

The profile sources dotfiles directly from the `lazuhyprDotfiles` directory:

### Home Directory Files
- `.zshrc` - Zsh configuration with modular loading
- `.tmux.conf` - Tmux configuration with plugins
- `.vimrc` - Vim configuration
- `.bashrc` - Bash configuration
- `.gtkrc-2.0` - GTK2 configuration
- `.Xresources` - X11 resources
- `.ideavimrc` - IntelliJ IDEA Vim configuration
- `.delta-themes.gitconfig` - Git delta themes

### Configuration Directories
- `.config/zshrc/` - Modular zsh configuration
- `.config/hypr/` - Hyprland configuration
- `.config/waybar/` - Waybar status bar
- `.config/rofi/` - Application launcher
- `.config/swaync/` - Notification center
- `.config/wlogout/` - Logout screen
- `.config/wezterm/` - Terminal emulator
- `.config/btop/` - System monitor
- `.config/lf/` - File manager
- `.config/ctpv/` - File preview
- `.config/mpv/` - Media player
- `.config/fastfetch/` - System info
- `.config/lsd/` - Modern ls
- `.config/spicetify/` - Spotify customization
- `.config/nvim/` - Neovim configuration
- `.config/ohmyposh/` - Shell prompt
- `.config/fish/` - Fish shell
- `.config/bashrc/` - Bash configuration

## Setup Instructions

1. **Apply the configuration**:
   ```bash
   home-manager switch --flake ~/path/to/your/flake#zrrg
   ```

2. **Setup Tmux Plugin Manager** (if using tmux):
   ```bash
   ./setup-tpm.sh
   ```

3. **Restart your shell** to load the new zsh configuration:
   ```bash
   exec zsh
   ```

## Key Packages

### Terminal & Shell
- `zsh` with syntax highlighting and autosuggestions
- `tmux` with plugin manager
- `kitty` and `wezterm` terminal emulators
- `fish` shell

### Editors
- `neovim` and `vim` with custom configurations
- `helix`, `kakoune`, `micro` for different editing styles
- Various IDEs: `lapce`, `lite-xl`, `kate`, `zed-editor`

### Development
- `git` with delta for better diffs
- `lazygit` for git TUI
- `glab` for GitLab CLI
- Various language servers and tools

### System Utilities
- `lf` and `ctpv` for file management
- `btop`, `fastfetch` for system monitoring
- `ripgrep`, `fd`, `bat` for searching and viewing
- `zoxide` for smart directory navigation

### Hyprland Ecosystem
- `waybar` for status bar
- `rofi-wayland` and `wofi` for launchers
- `swaynotificationcenter` for notifications
- `wlogout` for logout screen
- `grim`, `slurp`, `swappy` for screenshots

## Customization

The configuration is modular and can be easily customized:

1. **Zsh**: Add files to `~/.config/zshrc/custom/` or create `~/.zshrc_custom`
2. **Hyprland**: Modify the configuration in `wm/hyprland/default.nix`
3. **Packages**: Add or remove packages in `home.nix`
4. **Dotfiles**: Update the source paths in `default.nix`

## Troubleshooting

- If tmux plugins don't work, run the setup script: `./setup-tpm.sh`
- If zsh configuration doesn't load, check that the dotfiles are properly sourced
- For Hyprland issues, check the logs: `journalctl --user -f -g hyprland`

## Notes

- The configuration uses Brazilian Portuguese keyboard layout (`br` with `nodeadkeys`)
- GTK applications are configured for dark theme preference
- Fonts include Nerd Fonts for icons and Noto fonts for text
- The setup includes comprehensive aliases for modern CLI tools 