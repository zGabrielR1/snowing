# ❄️ Snowing - NixOS Configuration

A modern, modular NixOS configuration using flakes and Home Manager.

## 🏗️ Structure

```
snowing/
├── flake.nix                 # Main flake configuration
├── hosts/                    # Host-specific configurations
│   └── laptop/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/                  # Reusable modules
│   ├── nixos/               # NixOS modules
│   │   ├── default.nix
│   │   ├── audio.nix
│   │   ├── flatpak.nix
│   │   ├── hyprland.nix
│   │   ├── nix-settings.nix
│   │   └── ...
│   └── home/                # Home Manager modules
│       └── profiles/
│           └── zrrg/
│               ├── default.nix
│               ├── home.nix
│               └── wm/
│                   └── hyprland/
└── pkgs/                    # Custom packages
    └── windsurf/
```

## 🚀 Quick Start

### Prerequisites

- NixOS with flakes enabled
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/snowing.git
   cd snowing
   ```

2. **Switch to the configuration:**
   ```bash
   sudo nixos-rebuild switch --flake .#laptop
   ```

3. **Apply Home Manager configuration:**
   ```bash
   home-manager switch --flake .#zrrg
   ```

## 🔧 Development

### Development Shell

Enter the development shell for Nix-related tools:

```bash
nix develop
```

### Available Commands

- `nixpkgs-fmt` - Format Nix files
- `statix` - Lint Nix files
- `deadnix` - Find dead code in Nix files
- `alejandra` - Alternative Nix formatter

### Building

```bash
# Build the system
nix build .#nixosConfigurations.laptop.config.system.build.toplevel

# Build Home Manager
nix build .#homeConfigurations.zrrg.activationPackage
```

## 📦 Features

### System Features

- **Hyprland** - Modern Wayland compositor
- **PipeWire** - Audio system
- **Flatpak** - Application sandboxing
- **AppImage** - Application support
- **Firewall** - Network security
- **Auto-upgrade** - Automatic system updates

### User Features

- **Modern Shell Tools** - zsh, fzf, bat, eza, ripgrep
- **Development Tools** - neovim, git, lazygit, delta
- **Hyprland Ecosystem** - waybar, rofi, swaync
- **Theming** - pywal, spicetify

## 🎨 Customization

### Adding New Packages

1. **System packages:** Edit `modules/nixos/packages.nix`
2. **User packages:** Edit `modules/home/profiles/zrrg/home.nix`

### Adding New Hosts

1. Create a new directory in `hosts/`
2. Add configuration to `flake.nix`
3. Create `configuration.nix` and `hardware-configuration.nix`

### Adding New Modules

1. Create module in `modules/nixos/` or `modules/home/`
2. Import in the appropriate `default.nix`

## 🔒 Security

- Firewall enabled with common ports allowed
- User permissions properly configured
- Secure boot with systemd-boot
- Regular security updates

## 📚 Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `nixos-rebuild build-vm`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [NixOS Community](https://nixos.org/community/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Hyprland](https://hyprland.org/)
- [Chaotic Nyx](https://github.com/chaotic-cx/nyx) 