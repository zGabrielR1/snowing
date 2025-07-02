# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./user-configuration.nix
      ../../modules/nixos/hyprland.nix
      ../../modules/nixos/nix-settings.nix
      ../../modules/nixos/flatpak.nix
      ../../users
    ];

  # ============================================================================
  # BOOT CONFIGURATION
  # ============================================================================
  
  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Use testing kernel for latest features
  boot.kernelPackages = pkgs.linuxPackages_testing;
  # boot.readOnlyNixStore = false;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system - but minimize what gets pulled in
  #services.xserver.enable = true;
  
  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [
    "incusbr0" 
    "docker0" 
];

  # Enable SDDM with Makima theme
  #custom.sddm-theme.enable = true;

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  # Alternative display managers (commented out)
  #services.displayManager.sddm.enable = true;

  # Alternative desktop managers (commented out)
  #services.desktopManager.plasma6.enable = true;
  #services.xserver.desktopManager.xfce.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;
  #services.desktopManager.cinnamon.enable = true;
  #services.xserver.desktopManager.budgie.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  # Make shebang work.
  services.envfs.enable = true;

  # Enable sound with pipewire.

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.zrrg = {
    isNormalUser = true;
    description = "Gabriel Renostro";
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "incus-admin" 
      "podman" 
      "docker" 
      "video"
      "audio"
      "input"
      "kvm"
      "libvirtd"
    ];
    # Enable subuid/subgid for containers
    subGidRanges = [
      {
        count = 65536;
        startGid = 1000;
      }
    ];
    subUidRanges = [
      {
        count = 65536;
        startUid = 1000;
      }
    ];
  };

  # ============================================================================
  # HOME MANAGER CONFIGURATION
  # ============================================================================
  
  home-manager = {
    users.zrrg = {
      imports = [
        ../../modules/home/profiles/zrrg/default.nix
      ];
    };

    extraSpecialArgs = {
      inherit inputs;
      system = "x86_64-linux";
    };
  };

  # ============================================================================
  # PROGRAMS & PACKAGES
  # ============================================================================
  
  # Enable Firefox
  programs.firefox.enable = true;
  
  # Enable nix-ld with all necessary libraries
  custom.nix-ld.enable = true;
  
  # Enable AppImage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  
  # Enable Flatpak apps
  services.flatpak-apps = {
    flatseal.enable = true;
    kontainer.enable = true;
  };

}
