{ config, pkgs, lib, ... }:

let
  # Helper function to check if a desktop environment is enabled
  isDesktopEnabled = desktop: 
    if desktop == "gnome" then
      config.services.desktopManager.gnome.enable
    else if desktop == "kde" then
      config.services.desktopManager.plasma6.enable
    else
      false;

  # Determine which software center to enable
  enableGnomeSoftware = isDesktopEnabled "gnome" || (!isDesktopEnabled "kde");
  enableKdeDiscover = isDesktopEnabled "kde";
in
{
  # Enable Flatpak service
  services.flatpak.enable = true;

  # Add Flathub repository
  system.activationScripts.flatpak = lib.mkIf config.services.flatpak.enable ''
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';

  # Enable portal
  xdg.portal.enable = true;

  # Install Flatpak applications
  system.activationScripts.flatpakApps = lib.mkIf config.services.flatpak.enable ''
    # Install Zen Browser
    if ! ${pkgs.flatpak}/bin/flatpak list --app | grep -q "app.zen_browser.zen"; then
      ${pkgs.flatpak}/bin/flatpak install --noninteractive flathub app.zen_browser.zen
    fi

    # Install Kontainer
    if ! ${pkgs.flatpak}/bin/flatpak list --app | grep -q "io.github.DenysMb.Kontainer"; then
      ${pkgs.flatpak}/bin/flatpak install --noninteractive flathub io.github.DenysMb.Kontainer
    fi
  '';

  # Enable software centers through system packages
  environment.systemPackages = with pkgs; [
    (lib.mkIf enableGnomeSoftware gnome-software)
    (lib.mkIf enableKdeDiscover kdePackages.discover)
  ];

  # Additional KDE Connect requirement for Discover
  #programs.kdeconnect.enable = enableKdeDiscover;
  programs.kdeconnect = {
      enable = enableKdeDiscover;
      package = pkgs.gnomeExtensions.gsconnect;
  };
}
