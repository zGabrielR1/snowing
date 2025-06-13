# Windsurf Flake

This flake provides the latest version of Windsurf IDE, an agentic IDE powered by AI Flow paradigm.

## Features

- **Automatic Updates**: Fetches the latest version directly from Windsurf's API
- **No Manual Hash Checking**: Automatically handles SHA256 hashes
- **Multi-platform Support**: Supports Linux (x86_64) and macOS (x86_64, aarch64)

## Usage

The Windsurf package is automatically included in your home-manager configuration and will always be the latest version available.

### Manual Installation

If you want to install Windsurf manually in a development environment:

```bash
nix run .#windsurf
```

### Building from Source

```bash
nix build .#windsurf
```

## How It Works

1. The flake fetches the latest version information from Windsurf's API
2. It automatically downloads the correct binary for your platform
3. The package is built using the `vscode-generic` builder
4. No manual hash checking required - everything is handled automatically

## Updating

The flake automatically fetches the latest version every time you rebuild your system. To force an update:

```bash
nix flake update windsurf
nixos-rebuild switch
```

## Troubleshooting

If you encounter issues:

1. Check that your system is supported (x86_64-linux, x86_64-darwin, aarch64-darwin)
2. Ensure you have internet connectivity to fetch the latest version
3. Try running `nix flake update` to refresh the flake inputs

## License

Windsurf is proprietary software. See the package metadata for more details. 