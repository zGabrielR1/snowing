{ config, lib, pkgs, ... }:

{
  networking.nftables.enable = true;

  networking.firewall.trustedInterfaces = [
    "incusbr0"
    "docker0"
  ];

  # Uncomment and customize if you want to open specific ports
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}