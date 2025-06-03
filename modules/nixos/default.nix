# modules/nixos/default.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./audio.nix
    # ./fonts.nix       # Removed or commented out
    ./locale.nix
    ./networking.nix
    ./nix-settings.nix
    ./nh.nix
    ./packages.nix
    ./virtualization.nix
    # ./programs.nix
  ];
}
