# modules/nixos/default.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./audio.nix
    ./fonts.nix       
    ./flatpak.nix     
    ./gnome.nix
    ./locale.nix
    ./networking.nix
    ./nix-ld.nix     
    ./nix-settings.nix
    ./packages.nix
    ./sddm-theme.nix
    ./virtualization.nix
    #./vm-virtualization.nix  
    ./hyprland.nix
    ./utils.nix
    # ./programs.nix
  ];

  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg"; 
  };
  */
}
