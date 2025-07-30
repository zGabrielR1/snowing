# hosts/laptop/configuration.nix
# Host-specific configuration for the laptop system
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
  # SYSTEM IDENTIFICATION
  # ============================================================================
  
  networking.hostName = "nixos-laptop";
  system.stateVersion = "25.11";

  # ============================================================================
  # BOOT CONFIGURATION
  # ============================================================================
  
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    
    # Use testing kernel for latest hardware support
    kernelPackages = pkgs.linuxPackages_testing;
    
    # Performance optimizations
    kernel.sysctl = {
      # Network performance
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      
      # Memory management
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
    };
  };

  # ============================================================================
  # NETWORKING CONFIGURATION
  # ============================================================================
  
  networking = {
    networkmanager.enable = true;
    
    # Modern firewall with nftables
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "incusbr0" "docker0" ];
      allowedTCPPorts = [ 22 80 443 8080 ];
      allowedUDPPorts = [ 53 ];
    };
  };

  # Disable NetworkManager wait online for faster boot
  systemd.services.NetworkManager-wait-online.enable = false;

  # ============================================================================
  # DISPLAY AND DESKTOP ENVIRONMENT
  # ============================================================================
  
  # Enable Hyprland (configured in modules/nixos/hyprland.nix)
  programs.hyprland.enable = true;
  
  # GNOME as fallback desktop environment
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "br";
        variant = "nodeadkeys";
      };
    };
    
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  # ============================================================================
  # HARDWARE SUPPORT
  # ============================================================================
  
  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  
  # Input devices
  services.libinput.enable = true;
  console.keyMap = "br-abnt2";
  
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = lib.mkForce false; # Save power
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  
  # Printing
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplip epson-escpr ];
  };

  # ============================================================================
  # PROGRAMS AND SERVICES
  # ============================================================================
  
  programs = {
    # Web browsers
    firefox.enable = true;
    
    # AppImage support
    appimage = {
      enable = true;
      binfmt = true;
    };
    
    # Virtualization
    virt-manager.enable = true;
  };
  
  services = {
    # System utilities
    envfs.enable = true; # Make shebangs work
    tailscale.enable = true;
    
    # Flatpak applications
    flatpak-apps.flatseal.enable = true;
  };

  # ============================================================================
  # VIRTUALIZATION CONFIGURATION
  # ============================================================================
  
  virtualisation = {
    libvirtd.enable = true;
    
    # Advanced VM configuration with GPU passthrough
    vm = {
      enable = true;
      type = "virt-manager";
      username = "zrrg";
      
      vfio = {
        enable = true;
        platform = "intel";
        singleGpuPassthrough = true;
        hostGraphicsDriver = "i915";
        enableVgaSwitcheroo = true;
        blacklistGraphics = true;
        
        hugepages = {
          enable = true;
          size = "1G";
          count = 8;
        };
        
        lookingGlass = {
          enable = true;
          user = "zrrg";
        };
      };
      
      libvirt = {
        enableOvmf = true;
        enableSecureBoot = true;
        enableTpm = true;
        enableSpice = true;
      };
      
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
  };

  # ============================================================================
  # SECURITY AND OPTIMIZATION
  # ============================================================================
  
  # Security settings
  security = {
    rtkit.enable = true; # Real-time scheduling for audio
    polkit.enable = true;
    
    # AppArmor for additional security
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
  };
  
  # Performance optimizations
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave"; # Balance performance and power
  };
  
  # Automatic system maintenance
  system.autoUpgrade = {
    enable = false; # Disabled for flakes - use nh instead
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  # ============================================================================
  # ENVIRONMENT AND VARIABLES
  # ============================================================================
  
  environment = {
    # System-wide environment variables
    sessionVariables = {
      # Wayland
      NIXOS_OZONE_WL = "1";
      
      # XDG directories
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
    };
    
    # System packages (minimal - most packages in user config)
    systemPackages = with pkgs; [
      # Essential system tools
      vim
      wget
      curl
      git
      htop
      
      # Hardware utilities
      pciutils
      usbutils
      lshw
      
      # Network tools
      networkmanager
      wireless-tools
    ];
  };
}
