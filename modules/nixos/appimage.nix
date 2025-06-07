{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.appimage;
in {
  options.custom.appimage = {
    enable = mkEnableOption "AppImage support";
    binfmt = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable binfmt support for AppImages";
    };
  };

  config = mkIf cfg.enable {
    # Enable the built-in AppImage module
    programs.appimage.enable = true;
    
    # Configure binfmt if enabled
    boot.binfmt.registrations.appimage = mkIf cfg.binfmt {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF.....\x02\x00\x03\x00\x01\x00\x00\x00'';
    };
  };
} 