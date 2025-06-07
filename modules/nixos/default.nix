# modules/nixos/default.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./audio.nix
    # ./fonts.nix       # Removed or commented out
    ./flatpak.nix      # Added flatpak module
    ./locale.nix
    ./networking.nix
    ./nix-ld.nix       # Added nix-ld module
    ./nix-settings.nix
    ./nh.nix
    ./packages.nix
    ./virtualization.nix
    # ./programs.nix
  ];
}
