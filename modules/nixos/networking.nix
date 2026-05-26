{ config, lib, pkgs, ... }:

{
  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [
    "incusbr0"
    "docker0"
  ];
}
