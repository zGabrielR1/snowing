# modules/nixos/default.nix
# Main entry point for shared NixOS modules
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./locale.nix
    ./virtualization.nix
    ./audio.nix
    ./networking.nix
    ./packages.nix
    ./nix-settings.nix
  ];
}