#!/bin/bash
# Script to switch to a more stable configuration

echo "🔄 Switching to stable configuration to avoid compilation..."

# Create backup of current flake.lock
echo "💾 Creating backup of current flake.lock..."
cp flake.lock flake.lock.backup.$(date +%Y%m%d_%H%M%S)

# Update flake to use more stable inputs
echo "📦 Updating flake inputs to stable versions..."

# Update nixpkgs to stable
echo "Updating nixpkgs to stable..."
nix flake lock --update-input nixpkgs

# Update chaotic to stable
echo "Updating chaotic to stable..."
nix flake lock --update-input chaotic

# Update other inputs to stable versions
echo "Updating other inputs..."
nix flake update

echo "✅ Flake updated to stable versions!"
echo ""
echo "🚀 Now run the rebuild script:"
echo "./rebuild-no-compile.sh"
echo ""
echo "💡 If you still get compilation, you can:"
echo "1. Check what's being compiled with: ./check-compilation-causes.sh"
echo "2. Use nixpkgs stable instead of unstable in flake.nix"
echo "3. Remove custom packages temporarily" 