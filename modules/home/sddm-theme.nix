# modules/home/sddm-theme.nix
{ config, pkgs, lib, ... }:

{
  # Copy the Makima-SDDM theme files to the user's SDDM themes directory
  xdg.dataFile."sddm/themes/Makima-SDDM/theme.conf".source = ./Makima-SDDM/theme.conf;
  xdg.dataFile."sddm/themes/Makima-SDDM/Main.qml".source = ./Makima-SDDM/Main.qml;
  xdg.dataFile."sddm/themes/Makima-SDDM/metadata.desktop".source = ./Makima-SDDM/metadata.desktop;
  
  # Copy all files from Components directory
  xdg.dataFile."sddm/themes/Makima-SDDM/Components/".source = ./Makima-SDDM/Components;
  
  # Copy all files from Assets directory
  xdg.dataFile."sddm/themes/Makima-SDDM/Assets/".source = ./Makima-SDDM/Assets;
  
  # Copy all files from Backgrounds directory
  xdg.dataFile."sddm/themes/Makima-SDDM/Backgrounds/".source = ./Makima-SDDM/Backgrounds;
  
  # Copy all files from Previews directory
  xdg.dataFile."sddm/themes/Makima-SDDM/Previews/".source = ./Makima-SDDM/Previews;
  
  # Configure SDDM to use the theme
  xdg.configFile."sddm.conf".text = ''
    [Theme]
    Current=Makima-SDDM
  '';
} 