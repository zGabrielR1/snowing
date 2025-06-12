# Home Manager Modules

This directory contains home-manager modules for user-specific configurations.

## SDDM Theme Configuration

The `sddm-theme.nix` module provides automatic configuration for the Makima-SDDM theme.

### Features

- Automatically installs the Makima-SDDM theme to the user's SDDM themes directory
- Configures SDDM to use the Makima theme
- No manual file copying or configuration required

### Usage

The module is already imported in the user profile (`profiles/zrrg/default.nix`). When you enable SDDM in your NixOS configuration, the theme will be automatically available and configured.

### Manual Configuration (if needed)

If you need to manually configure SDDM, the theme files will be available at:
- `~/.local/share/sddm/themes/Makima-SDDM/`
- SDDM configuration: `~/.config/sddm.conf`

### Theme Customization

You can customize the theme by editing the `theme.conf` file in the theme directory. The theme supports various customization options including:

- Background image and blur settings
- Color schemes
- Form positioning
- Font settings
- Interface behavior

For more details, see the theme's documentation in `Makima-SDDM/README.md`. 