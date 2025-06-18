{ config, lib, ... }:
{
  # Enable pre-installation of Flatpak apps by default for the user
  #services.flatpak-apps.refine.enable = lib.mkDefault true;
  services.flatpak-apps.flatseal.enable = lib.mkDefault true;
  services.flatpak-apps.kontainer.enable = lib.mkDefault true;
} 