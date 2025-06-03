{ config, lib, pkgs, ... }:

{
  virtualisation.containers.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    docker.enable = true;
    incus.enable = true;
  };
}