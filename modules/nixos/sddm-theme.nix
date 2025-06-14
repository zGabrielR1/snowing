{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.custom.sddm-theme;
  
  # Create the Makima theme package
  makima-theme = pkgs.stdenv.mkDerivation {
    pname = "makima-sddm-theme";
    version = "1.0.0";
    
    src = pkgs.fetchFromGitHub {
      owner = "Arnau029";
      repo = "Makima-SDDM";
      rev = "7d1cf858e07fa6a5160add8d0a21afedfd24f2c4";
      sha256 = "sha256-N/h0feb9GNTDYsv4qc2syy12sUWx1x2SOAJyfjV8ZAo=";
    };
    
    installPhase = ''
      mkdir -p $out/share/sddm/themes/Makima-SDDM
      cp -r * $out/share/sddm/themes/Makima-SDDM/
    '';
    
    meta = {
      description = "Makima SDDM Theme from Chainsaw Man";
      homepage = "https://github.com/Arnau029/Makima-SDDM";
      license = lib.licenses.mit;
    };
  };
in {
  options.custom.sddm-theme = {
    enable = mkEnableOption "Enable custom SDDM theme";
    theme = mkOption {
      type = types.str;
      default = "Makima-SDDM";
      description = "Name of the SDDM theme to use";
    };
  };

  config = mkIf cfg.enable {
    # Install the theme package
    environment.systemPackages = [ makima-theme ];
    
    # Configure SDDM to use the theme
    services.displayManager.sddm = {
      enable = true;
      theme = cfg.theme;
    };
    
    # Install required fonts for the theme
    fonts.packages = with pkgs; [
      noto-fonts-cjk-sans
      ipafont
    ];
  };
} 