# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix
    ./user-configuration.nix
    
    # NixOS modules (imported via modules/nixos/default.nix)
    # Individual modules are auto-imported, no need to specify each one
    
    # User configurations
    ../../users
  ];

  # ============================================================================
  # SNOWING CONFIGURATION
  # ============================================================================
  
  # Define users for the snowing system
  snowing.data.users = ["zrrg"];
  
  # Enable wine with all features
  snowing.programs.wine = {
    enable = true;
    ntsync.enable = true;
    wayland.enable = true;
    ge-proton.enable = true;
  };
  
  # Enable graphics support
  snowing.graphics = {
    enable = true;
    intel.enable = true;
  };
  
  # Enable services
  snowing.services = {
    enable = true;
    tailscale = {
      enable = true;
      exitNode.enable = false;
    };
    openssh.enable = false;
  };

  # ============================================================================
  # BOOT CONFIGURATION
  # ============================================================================
  
  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Use testing kernel for latest features
 # boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmp.cleanOnBoot = true;
# boot.readOnlyNixStore = false;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  # Enable the X11 windowing system - but minimize what gets pulled in
  #services.xserver.enable = true;
  
  networking = {
    networkmanager.enable = true;

    # Modern firewall with nftables
    nftables.enable = true;
    firewall = {
      enable = true;

      # Trusted interfaces for virtual machines and containers
      trustedInterfaces = [ "incusbr0" "docker0" "virbr0" ];

      # Allowed ports with specific purposes
      allowedTCPPorts = [
        22    # SSH
        80    # HTTP
        443   # HTTPS
        8080  # Alternative HTTP
        1143  # IMAPS
        993   # IMAPS (alternative)
        587   # SMTP submission
      ];

      allowedUDPPorts = [
        53    # DNS
        67    # DHCP server
        68    # DHCP client
        51820 # WireGuard
        5353  # mDNS
      ];

      # Additional security measures
      allowPing = true;
      logRefusedConnections = false;  # Set to true for debugging
      logRefusedPackets = false;
    };
  };


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
        startGid = 10000;
      }
    ];
    subUidRanges = [
      {
        count = 65536;
        startUid = 10000;
      }
    ];
  };

  # Home Manager configured at flake-level

  # ============================================================================
  # NIX & PACKAGE MANAGEMENT
  # ============================================================================
  
  # Enable Firefox
  #programs.firefox.enable = true;
  programs.localsend.enable = true;
  # Enable nix-ld with all necessary libraries
  custom.nix-ld.enable = true;
  
  # Enable AppImage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  

  #Enable Tailscale
  services.tailscale.enable = true;

  #Enable Jellyfin
  services.jellyfin.enable = true;

  hardware.bluetooth.powerOnBoot = false;

  # disable network manager wait online service (+6 seconds to boot time!!!!)
  systemd.services.NetworkManager-wait-online.enable = false;

  # ============================================================================
  # VIRTUALIZATION CONFIGURATION
  # ============================================================================

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  
  # Enable basic virt-manager with QEMU/KVM and IOMMU
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
    
    # VFIO/GPU Passthrough configuration
    vfio = {
      enable = true;
      platform = "intel";  # Intel CPU with IOMMU
      singleGpuPassthrough = true;  # Enable single GPU passthrough
      hostGraphicsDriver = "i915";  # Intel iGPU for host when VM is not running
      enableVgaSwitcheroo = true;   # Enable dynamic GPU switching
      blacklistGraphics = true;      # Blacklist conflicting graphics drivers
      
      # HugePages for better performance
      hugepages = {
        enable = true;
        size = "1G";
        count = 8;
      };
      
      # Looking Glass support for better VM display performance
      lookingGlass = {
        enable = true;
        user = "zrrg";
      };
    };
    
    # Libvirt configuration
    libvirt = {
      enableOvmf = true;       # UEFI firmware support
      enableSecureBoot = true; # Secure Boot in OVMF
      enableTpm = true;        # TPM 2.0 emulation
      enableSpice = true;      # SPICE protocol for better VM display
    };
    
    # Performance tuning
    performance = {
      enable = true;
      cpu = {
        enable = true;
        governor = "performance";
      };
      network = {
        enable = true;
        tcpFastOpen = true;
      };
    };
  };

  system.stateVersion = "25.11";
}
