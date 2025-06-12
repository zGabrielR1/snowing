# modules/nixos/sddm.nix
{ config, pkgs, lib, ... }:

{
  # Enable SDDM display manager
  services.displayManager.sddm = {
    enable = true;
    theme = "Makima-SDDM";
  };

<<<<<<< HEAD
  # Copy the Makima-SDDM theme to the system SDDM themes directory
  environment.etc."sddm/themes/Makima-SDDM".source = ./Makima-SDDM;
=======
  # Install the Makima-SDDM theme system-wide
  environment.systemPackages = with pkgs; [
    # Create a package for the Makima-SDDM theme
    (pkgs.stdenv.mkDerivation {
      pname = "makima-sddm-theme";
      version = "1.1";
      
      src = ./Makima-SDDM;
      
      installPhase = ''
        mkdir -p $out/share/sddm/themes/Makima-SDDM
        cp -r * $out/share/sddm/themes/Makima-SDDM/
      '';
      
      meta = with lib; {
        description = "Makima SDDM theme";
        homepage = "https://github.com/Asher029/Makima-SDDM";
        license = licenses.mit;
        platforms = platforms.linux;
      };
    })
  ];
>>>>>>> 33e8d5f (.)
} 