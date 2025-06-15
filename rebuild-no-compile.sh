#!/bin/bash
# Rebuild script optimized to avoid compilation

echo "🚀 Rebuilding NixOS with maximum cache usage..."

# First, update the flake inputs to get latest cached packages
echo "📦 Updating flake inputs..."
nix flake update

# Build with maximum cache usage
echo "🔧 Building system configuration..."
sudo nixos-rebuild switch --flake .#laptop \
  --option substituters "https://cache.nixos.org https://zgabrielr.cachix.org https://hyprland.cachix.org https://nix-community.cachix.org https://chaotic-nyx.cachix.org https://numtide.cachix.org https://divnix.cachix.org https://nixpkgs-wayland.cachix.org https://nix-gaming.cachix.org https://colmena.cachix.org https://nrdxp.cachix.org https://anyrun.cachix.org https://fufexan.cachix.org https://helix.cachix.org https://niri.cachix.org https://nixpkgs-update.cachix.org https://mic92.cachix.org https://dram.cachix.org" \
  --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= zgabrielr.cachix.org-1:DNsXs3NCf3sVwby1O2EMD5Ai/uu1Z1uswKSh47A1mvw= hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= divnix.cachix.org-1:U8QPQF411uJGX3mW9E1ojuFu6QLJrrUETcOEjBuBYHg= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8= nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4= colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg= nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s= fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY= helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs= niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964= nixpkgs-update.cachix.org-1:6y6Z2JdoL3APdu6/+Iy8eZX2ajf09e4EE9SnxSML1W8= mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ= dram.cachix.org-1:baoy1SXpwYdKbqdTbfKGTKauDDeDlHhUpC+QuuILEMY=" \
  --option builders-use-substitutes true \
  --option auto-optimise-store true \
  --max-jobs 1 \
  --cores 1

echo "✅ Rebuild complete!" 