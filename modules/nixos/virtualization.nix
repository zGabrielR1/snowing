{ config, lib, pkgs, ... }:

{
  virtualisation.containers.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    
    # Alternative container runtimes (disabled):
    # docker = {
    #   enable = true;
    #   rootless = {
    #     enable = true;
    #     setSocketVariable = true;
    #   };
    # };
    # incus.enable = true;
  };
}