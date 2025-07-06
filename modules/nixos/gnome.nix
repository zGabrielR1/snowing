{ config, lib, pkgs, ... }:

lib.mkIf (!config.services.desktopManager.gnome.enable) {
  # Enable GNOME services
  services.gnome = {
    # Enable GNOME keyring for secure storage
    gnome-keyring.enable = true;
    
    # Enable GNOME settings daemon for night light and other features
    gnome-settings-daemon.enable = true;
  };

  # Enable power management (night light may depend on this)
  services.upower.enable = true;

  # Enable GNOME extensions support
  programs.gnome-terminal.enable = true;
  
  # Enable dconf for GNOME settings
  programs.dconf.enable = true;
} 