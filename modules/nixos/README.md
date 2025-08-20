# Snowing NixOS Modules

This directory contains the NixOS modules for the Snowing configuration system, providing a modular and organized approach to system configuration management.

## Module Organization

Modules are organized by functionality and follow consistent naming conventions:

### Core System Modules
- `default.nix` - Main module with options and auto-imports
- `packages.nix` - System-wide packages
- `services.nix` - System services configuration
- `utils.nix` - Utility functions and helpers

### Hardware & Graphics
- `audio.nix` - Audio configuration and pipewire setup
- `bluetooth.nix` - Bluetooth support
- `graphics.nix` - Graphics drivers and GPU configuration
- `networking.nix` - Network configuration

### Desktop Environment
- `gnome.nix` - GNOME desktop environment
- `hyprland.nix` - Hyprland window manager

### Applications & Tools
- `appimage.nix` - AppImage support
- `flatpak.nix` - Flatpak package management
- `fonts.nix` - System fonts configuration
- `snap.nix` - Snap package support
- `wine.nix` - Wine/Proton configuration

### Development & Utilities
- `locale.nix` - Localization settings
- `nix-ld.nix` - Dynamic linker for binaries
- `nix-settings.nix` - Nix package manager settings
- `virtualization.nix` - VM and container support

## Configuration System

The Snowing configuration system provides a modular approach to NixOS configuration with the following structure:

### `config.snowing.data`
- `users`: List of users for the system
- `headless`: Enable headless system mode

### `config.snowing.programs`
- `wine`: Wine configuration with options for ntsync, wayland, and ge-proton

### `config.snowing.services`
- `enable`: Enable services module
- `tailscale`: Tailscale configuration with exit node support
- `openssh`: OpenSSH configuration

### `config.snowing.graphics`
- `enable`: Enable graphics support
- `intel`: Intel graphics support
- `nvidia`: NVIDIA graphics support
- `amd`: AMD graphics support

## Usage Example

```nix
{
  # Define users
  snowing.data.users = ["zrrg"];
  
  # Enable wine with all features
  snowing.programs.wine = {
    enable = true;
    ntsync.enable = true;
    wayland.enable = true;
    ge-proton.enable = true;
  };
  
  # Enable graphics support
  snowing.graphics = {
    enable = true;
    intel.enable = true;
  };
  
  # Enable services
  snowing.services = {
    enable = true;
    tailscale = {
      enable = true;
      exitNode.enable = false;
    };
    openssh.enable = true;
  };
}
```

## Modules

- `wine.nix`: Wine configuration with Proton GE support
- `graphics.nix`: Graphics drivers and OpenGL configuration
- `services.nix`: Common services like Tailscale and OpenSSH
- `default.nix`: Main module that defines all options and imports other modules

## Auto-import

All `.nix` files in this directory are automatically imported by `default.nix`, so you can add new modules without manually importing them.
