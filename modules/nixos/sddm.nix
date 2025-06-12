# modules/nixos/sddm.nix
{ config, pkgs, lib, ... }:

{
  # Enable SDDM display manager
  services.displayManager.sddm = {
    enable = true;
    theme = "Makima-SDDM";
  };

  # Copy the Makima-SDDM theme to the system SDDM themes directory
  environment.etc."sddm/themes/Makima-SDDM".source = ./Makima-SDDM;
} 