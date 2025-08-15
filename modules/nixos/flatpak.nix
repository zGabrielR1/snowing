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

  # List of Flatpak apps to manage as options
  flatpakAppDefs = [
    { option = "refine";      id = "page.tesk.Refine";           description = "Enable pre-installation of the Refine Flatpak app."; }
    { option = "flatseal";    id = "com.github.tchx84.Flatseal"; description = "Enable pre-installation of the Flatseal Flatpak app."; }
    { option = "zen_browser"; id = "app.zen_browser.zen";        description = "Enable pre-installation of the Zen Browser Flatpak app."; }
  ];

  # Generate options for each app
  flatpakAppOptions = lib.listToAttrs (map (app: {
    name = app.option;
    value = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = app.description;
      };
    };
  }) flatpakAppDefs);

  # Get enabled apps and generate install commands
  enabledFlatpakApps = lib.filter (app: config.services.flatpak-apps.${app.option}.enable) flatpakAppDefs;
  installCmds = lib.concatStringsSep "\n" (map (app: ''
    if ! ${pkgs.flatpak}/bin/flatpak list --app | grep -q "${app.id}"; then
      ${pkgs.flatpak}/bin/flatpak install --noninteractive flathub ${app.id} || echo "Failed to install ${app.id}"
    fi
  '') enabledFlatpakApps);
in
{
  options = {
    services.flatpak-apps = flatpakAppOptions;
  };

  config = {
    services.flatpak.enable = true;
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdg.portal.config.common.default = "gtk";

    systemd.services.flatpak-setup = lib.mkIf config.services.flatpak.enable {
      description = "Setup Flatpak repositories and applications";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart =
          (pkgs.writeShellScript "flatpak-setup" ''
            ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            ${pkgs.flatpak}/bin/flatpak update --appstream
            ${pkgs.flatpak}/bin/flatpak remote-modify --enable flathub
          '');
      };
    };

    systemd.services.flatpak-apps = lib.mkIf (config.services.flatpak.enable && enabledFlatpakApps != []) {
      description = "Install Flatpak applications";
      wantedBy = [ "multi-user.target" ];
      after = [ "flatpak-setup.service" ];
      requires = [ "flatpak-setup.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart =
          (pkgs.writeShellScript "flatpak-apps-install" ''
            ${installCmds}
          '');
      };
    };

    environment.systemPackages = with pkgs; [
      (lib.mkIf enableGnomeSoftware gnome-software)
      (lib.mkIf enableKdeDiscover kdePackages.discover)
    ];

    programs.kdeconnect = {
      enable = enableKdeDiscover;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };
}
