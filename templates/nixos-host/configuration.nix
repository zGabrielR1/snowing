# hosts/<hostname>/configuration.nix
# Host-specific configuration template
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # Hardware configuration (generate with: nixos-generate-config)
    ./hardware-configuration.nix
    
    # User-specific configuration
    ./user-configuration.nix
    
    # User configurations
    ../../users
  ];

  # ============================================================================
  # SYSTEM IDENTIFICATION
  # ============================================================================
  
  networking.hostName = "HOSTNAME"; # Replace with actual hostname
  system.stateVersion = "25.11"; # Set to your NixOS version

  # ============================================================================
  # BOOT CONFIGURATION
  # ============================================================================
  
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    
    # Choose appropriate kernel
    kernelPackages = pkgs.linuxPackages; # or linuxPackages_testing for latest
  };

  # ============================================================================
  # NETWORKING CONFIGURATION
  # ============================================================================
  
  networking = {
    networkmanager.enable = true;
    
    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]; # SSH
      allowedUDPPorts = [ ];
    };
  };

  # ============================================================================
  # DESKTOP ENVIRONMENT (customize as needed)
  # ============================================================================
  
  # Enable display server
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us"; # Change to your layout
      variant = "";
    };
  };
  
  # Choose desktop environment
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # ============================================================================
  # HARDWARE SUPPORT
  # ============================================================================
  
  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # Input devices
  services.libinput.enable = true;
  
  # Printing (if needed)
  # services.printing.enable = true;

  # ============================================================================
  # PROGRAMS AND SERVICES
  # ============================================================================
  
  programs = {
    firefox.enable = true;
  };
  
  # Add host-specific services here
  services = {
    openssh.enable = true; # Enable SSH
  };

  # ============================================================================
  # SECURITY AND OPTIMIZATION
  # ============================================================================
  
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };
  
  # ============================================================================
  # ENVIRONMENT
  # ============================================================================
  
  environment = {
    systemPackages = with pkgs; [
      # Essential system tools
      vim
      wget
      curl
      git
      htop
    ];
  };
}