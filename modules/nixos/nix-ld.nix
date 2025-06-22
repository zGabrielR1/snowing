{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.custom.nix-ld;
in {
  imports = [
    inputs.nix-ld.nixosModules.nix-ld
  ];

  options.custom.nix-ld = {
    enable = mkEnableOption "nix-ld support";
    libraries = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        # GLib and related libraries
        glib
        glib-networking
        gobject-introspection
        
        # NSS components
        nss
        nspr
        
        # System libraries
        dbus
        libdbusmenu-gtk3
        systemd # For libudev.so.1
        
        # GTK and display related
        gtk3
        atk
        at-spi2-atk
        at-spi2-core
        cups
        libdrm
        pango
        cairo
        xorg.libX11
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXrandr
        mesa
        libgbm
        
        # Other dependencies
        libxkbcommon
        expat
        xorg.libxcb
        alsa-lib
        
        # Special handling for libffmpeg.so
        ffmpeg-full
      ];
      description = "List of libraries to be made available to nix-ld";
    };
  };

  config = mkIf cfg.enable {
    # Enable the nix-ld flake module (dev version to avoid collision with built-in)
    programs.nix-ld.dev.enable = true;
    # Set the libraries
    programs.nix-ld.dev.libraries = cfg.libraries;
  };
} 