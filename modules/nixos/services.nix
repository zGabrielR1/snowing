{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.snowing.services;
in {
  options.snowing.services = {
    enable = mkEnableOption "services";
    tailscale = {
      enable = mkEnableOption "tailscale";
      exitNode.enable = mkEnableOption "tailscale exit node";
    };
    openssh.enable = mkEnableOption "openssh";
  };

  config = mkIf cfg.enable {
    # Tailscale configuration
    services.tailscale = mkIf cfg.tailscale.enable {
      enable = true;
      useRoutingFeatures = if cfg.tailscale.exitNode.enable then "both" else "client";
    };

    # OpenSSH configuration
    services.openssh = mkIf cfg.openssh.enable {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
      };
    };

    # Common service configurations
    services = {
      # CUPS for printing
      printing.enable = true;
      
      # Bluetooth
      blueman.enable = true;
      
      # Pipewire for audio
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };

    # NetworkManager lives under networking
    networking.networkmanager.enable = true;
  };
}
