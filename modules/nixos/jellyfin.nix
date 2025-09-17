{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.snowing.services.jellyfin;
in

{
  options = {
    snowing.services.jellyfin = {
      enable = mkEnableOption "Jellyfin media server";
    };
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;

    };
    environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];

  };
}
