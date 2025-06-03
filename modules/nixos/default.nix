# modules/nixos/default.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./audio.nix
    ./fonts.nix       # Moved from system/programs/fonts.nix
    ./locale.nix
    ./networking.nix
    ./nix-settings.nix # This is the single source of truth for nix settings
    ./nh.nix          # Moved from system/nix/nh.nix
    ./packages.nix
    ./virtualization.nix
    # Add a new module for general program settings if desired
    # ./programs.nix
  ];
}
