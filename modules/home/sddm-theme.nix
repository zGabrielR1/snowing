# modules/home/sddm-theme.nix
{ config, pkgs, lib, ... }:

{
  # Copy the Makima-SDDM theme files to the user's SDDM themes directory
  xdg.dataFile."sddm/themes/Makima-SDDM/theme.conf".source = ./Makima-SDDM/theme.conf;
  xdg.dataFile."sddm/themes/Makima-SDDM/Main.qml".source = ./Makima-SDDM/Main.qml;
  xdg.dataFile."sddm/themes/Makima-SDDM/metadata.desktop".source = ./Makima-SDDM/metadata.desktop;
  
  # Copy individual files from Components directory
  xdg.dataFile."sddm/themes/Makima-SDDM/Components/UserList.qml".source = ./Makima-SDDM/Components/UserList.qml;
  xdg.dataFile."sddm/themes/Makima-SDDM/Components/VirtualKeyboard.qml".source = ./Makima-SDDM/Components/VirtualKeyboard.qml;
  xdg.dataFile."sddm/themes/Makima-SDDM/Components/LoginForm.qml".source = ./Makima-SDDM/Components/LoginForm.qml;
  xdg.dataFile."sddm/themes/Makima-SDDM/Components/SessionButton.qml".source = ./Makima-SDDM/Components/SessionButton.qml;
  xdg.dataFile."sddm/themes/Makima-SDDM/Components/SystemButtons.qml".source = ./Makima-SDDM/Components/SystemButtons.qml;
  xdg.dataFile."sddm/themes/Makima-SDDM/Components/Input.qml".source = ./Makima-SDDM/Components/Input.qml;
  xdg.dataFile."sddm/themes/Makima-SDDM/Components/Clock.qml".source = ./Makima-SDDM/Components/Clock.qml;
  
  # Copy individual files from Assets directory
  xdg.dataFile."sddm/themes/Makima-SDDM/Assets/User.svg".source = ./Makima-SDDM/Assets/User.svg;
  xdg.dataFile."sddm/themes/Makima-SDDM/Assets/Shutdown.svg".source = ./Makima-SDDM/Assets/Shutdown.svg;
  xdg.dataFile."sddm/themes/Makima-SDDM/Assets/Suspend.svg".source = ./Makima-SDDM/Assets/Suspend.svg;
  xdg.dataFile."sddm/themes/Makima-SDDM/Assets/Hibernate.svg".source = ./Makima-SDDM/Assets/Hibernate.svg;
  xdg.dataFile."sddm/themes/Makima-SDDM/Assets/Reboot.svg".source = ./Makima-SDDM/Assets/Reboot.svg;
  
  # Copy individual files from Backgrounds directory
  xdg.dataFile."sddm/themes/Makima-SDDM/Backgrounds/background.png".source = ./Makima-SDDM/Backgrounds/background.png;
  
  # Copy individual files from Previews directory
  xdg.dataFile."sddm/themes/Makima-SDDM/Previews/Right.png".source = ./Makima-SDDM/Previews/Right.png;
  xdg.dataFile."sddm/themes/Makima-SDDM/Previews/Left.png".source = ./Makima-SDDM/Previews/Left.png;
  xdg.dataFile."sddm/themes/Makima-SDDM/Previews/Center.png".source = ./Makima-SDDM/Previews/Center.png;
  
  # Configure SDDM to use the theme
  xdg.configFile."sddm.conf".text = ''
    [Theme]
    Current=Makima-SDDM
  '';
} 