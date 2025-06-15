{ config, lib, pkgs, ... }:

{
  # Enable GNOME services
  services.gnome = {
    # Enable GNOME keyring for secure storage
    gnome-keyring.enable = true;
    
    # Enable GNOME settings daemon for night light and other features
    gnome-settings-daemon.enable = true;
  };

  # Enable geoclue2 for location services (required for night light)
  services.geoclue2 = {
    enable = true;
    # Allow GNOME to access location data
    appConfig = {
      "org.gnome.Settings" = {
        isAllowed = true;
        isSystem = false;
      };
      "org.gnome.Shell" = {
        isAllowed = true;
        isSystem = false;
      };
      "org.gnome.SettingsDaemon.Color" = {
        isAllowed = true;
        isSystem = false;
      };
    };
  };

  # Enable location services
  location.provider = "geoclue2";

  # Enable GNOME user services
  services.dbus.enable = true;
  
  # Enable power management (night light may depend on this)
  services.upower.enable = true;
  
  # Enable GNOME settings daemon
  services.gnome.gnome-settings-daemon.enable = true;

  # Add necessary packages for GNOME night light
  environment.systemPackages = with pkgs; [
    gnome.gnome-settings-daemon
    gnome.gnome-control-center
    gnome.gnome-shell
    geoclue2
  ];

  # Enable GNOME extensions support
  programs.gnome-terminal.enable = true;
  
  # Enable dconf for GNOME settings
  programs.dconf.enable = true;
} 