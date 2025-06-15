#!/bin/bash
# Script to check what's causing compilation

echo "🔍 Checking what packages might cause compilation..."

echo "📊 Checking flake inputs for potential compilation triggers..."
echo "Current flake inputs:"
nix flake metadata . --json | jq -r '.locks.nodes | to_entries[] | select(.value.type == "github") | "  \(.key): \(.value.original.ref // "default")"'

echo ""
echo "🔧 Checking for packages that might need compilation..."

# Check if any packages are marked as unfree or broken
echo "Checking nixpkgs configuration..."
nix eval .#nixosConfigurations.laptop.config.nixpkgs.config --apply 'cfg: { allowUnfree = cfg.allowUnfree or false; allowBroken = cfg.allowBroken or false; }'

echo ""
echo "📦 Checking for custom packages that might not be cached..."
if [ -d "./pkgs" ]; then
    echo "Custom packages found in ./pkgs:"
    find ./pkgs -name "*.nix" -type f
fi

echo ""
echo "🚀 Recommendations to avoid compilation:"
echo "1. Use stable channels instead of unstable where possible"
echo "2. Avoid custom packages that aren't in caches"
echo "3. Use pre-built kernels instead of latest/testing"
echo "4. Consider using nixpkgs stable instead of unstable"
echo "5. Check if chaotic-nyx packages are available in caches"

echo ""
echo "💡 To see what's actually being built, run:"
echo "sudo nixos-rebuild switch --flake .#laptop --dry-run" 