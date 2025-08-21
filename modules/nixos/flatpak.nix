{ config, pkgs, lib, ... }:

{
  config = {
    services.flatpak.enable = true;
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdg.portal.config.common.default = "gtk";

    systemd.services.flatpak-setup = lib.mkIf config.services.flatpak.enable {
      description = "Setup Flatpak repositories";
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
  };
}
