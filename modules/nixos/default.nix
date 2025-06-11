# modules/nixos/default.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./audio.nix
    ./fonts.nix       
    ./flatpak.nix     
    ./locale.nix
    ./networking.nix
    ./nix-ld.nix     
    ./nix-settings.nix
    ./packages.nix
    ./virtualization.nix
    #./vm-virtualization.nix  
    ./vm-virtualization.nix  
    ./hyprland.nix
    ./utils.nix
    # ./programs.nix
  ];
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";  # Replace with your actual username
  };
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";  # Replace with your actual username
  };
  */
}
