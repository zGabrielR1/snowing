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

  # Enable portal
  xdg.portal.enable = true;

  # Systemd service to add Flathub repository after networking is available
  systemd.services.flatpak-setup = lib.mkIf config.services.flatpak.enable {
    description = "Setup Flatpak repositories and applications";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo'";
      ExecStartPost = "${pkgs.bash}/bin/bash -c '${pkgs.flatpak}/bin/flatpak update --appstream'";
      ExecStartPost = "${pkgs.bash}/bin/bash -c '${pkgs.flatpak}/bin/flatpak remote-modify --enable flathub'";
    };
  };

  # Systemd service to install Flatpak applications after repository setup
  systemd.services.flatpak-apps = lib.mkIf config.services.flatpak.enable {
    description = "Install Flatpak applications";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-setup.service" ];
    requires = [ "flatpak-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '
        # Install Kontainer
        if ! ${pkgs.flatpak}/bin/flatpak list --app | grep -q \"io.github.DenysMb.Kontainer\"; then
          ${pkgs.flatpak}/bin/flatpak install --noninteractive flathub io.github.DenysMb.Kontainer || echo \"Failed to install Kontainer\"
        fi

        # Install Flatseal
        if ! ${pkgs.flatpak}/bin/flatpak list --app | grep -q \"com.github.tchx84.Flatseal\"; then
          ${pkgs.flatpak}/bin/flatpak install --noninteractive flathub com.github.tchx84.Flatseal || echo \"Failed to install Flatseal\"
        fi
      '";
    };
  };

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
