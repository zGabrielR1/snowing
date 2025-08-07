{
  pkgs,
  config,
  outputs,
  lib,
  ...
}: let
  username = "zrrg";
  description = "Gabriel Renostro";
in {
  # Add user to snowing data.users list
  snowing.data.users = [username];
  
  users.users.${username} = {
    inherit description;
    isNormalUser = true;
    extraGroups = [
      "networkmanager" 
      "wheel" 
      "incus-admin" 
      "podman" 
      "docker" 
      "multimedia"
      "video"
      "audio"
      "input"
      "kvm"
      "libvirtd"
      "lp"
      "scanner"
    ];
    
    # Common packages for all hosts - moved to user-configuration.nix to avoid duplication
    packages = [ ];
  };

  # Hjem configuration for dotfile management
  hjem.users.${username} = {
    enable = true;
    user = username;
    directory = config.users.users.${username}.home;
    clobberFiles = lib.mkForce true;

    files = {
      # ============================================================================
      # SHELL CONFIGURATIONS
      # ============================================================================
      
      # Shell configurations
      ".zshrc".source = ../modules/home/lazuhyprDotfiles/.zshrc;
      ".bashrc".source = ../modules/home/lazuhyprDotfiles/.bashrc;
      ".config/zshrc".source = ../modules/home/lazuhyprDotfiles/.config/zshrc;
      ".config/bashrc".source = ../modules/home/lazuhyprDotfiles/.config/bashrc;
      ".config/fish".source = ../modules/home/lazuhyprDotfiles/.config/fish;

      # ============================================================================
      # TERMINAL & EDITOR CONFIGURATIONS
      # ============================================================================
      
      # Terminal and editor configurations
      ".tmux.conf".source = ../modules/home/lazuhyprDotfiles/.tmux.conf;
      ".vimrc".source = ../modules/home/lazuhyprDotfiles/.vimrc;
      ".ideavimrc".source = ../modules/home/lazuhyprDotfiles/.ideavimrc;
      ".config/nvim".source = ../modules/home/lazuhyprDotfiles/.config/nvim;
      ".config/wezterm".source = ../modules/home/lazuhyprDotfiles/.config/wezterm;
      ".config/btop".source = ../modules/home/lazuhyprDotfiles/.config/btop;
      ".config/ohmyposh".source = ../modules/home/lazuhyprDotfiles/.config/ohmyposh;

      # ============================================================================
      # DESKTOP & THEMING
      # ============================================================================
      
      # X11 and GTK configurations
      ".gtkrc-2.0".source = ../modules/home/lazuhyprDotfiles/.gtkrc-2.0;
      # ".Xresources".source = ../modules/home/lazuhyprDotfiles/.Xresources;

      # ============================================================================
      # DEVELOPMENT TOOLS
      # ============================================================================
      
      # Git delta themes
      ".delta-themes.gitconfig".source = ../modules/home/lazuhyprDotfiles/.delta-themes.gitconfig;

      # ============================================================================
      # FILE MANAGEMENT
      # ============================================================================
      
      # Stow configuration
      ".stow-local-ignore".source = ../modules/home/lazuhyprDotfiles/.stow-local-ignore;
      ".config/lf".source = ../modules/home/lazuhyprDotfiles/.config/lf;
      ".config/ctpv".source = ../modules/home/lazuhyprDotfiles/.config/ctpv;

      # ============================================================================
      # WINDOW MANAGER & DESKTOP ENVIRONMENT
      # ============================================================================
      
      # Hyprland ecosystem
      ".config/hypr".source = ../modules/home/lazuhyprDotfiles/.config/hypr;
      ".config/waybar".source = ../modules/home/lazuhyprDotfiles/.config/waybar;
      ".config/rofi".source = ../modules/home/lazuhyprDotfiles/.config/rofi;
      ".config/swaync".source = ../modules/home/lazuhyprDotfiles/.config/swaync;
      ".config/wlogout".source = ../modules/home/lazuhyprDotfiles/.config/wlogout;

      # ============================================================================
      # MULTIMEDIA & ENTERTAINMENT
      # ============================================================================
      
      # Media players and entertainment
      ".config/mpv".source = ../modules/home/lazuhyprDotfiles/.config/mpv;
      ".config/spicetify".source = ../modules/home/lazuhyprDotfiles/.config/spicetify;

      # ============================================================================
      # SYSTEM UTILITIES
      # ============================================================================
      
      # System monitoring and utilities
      ".config/fastfetch".source = ../modules/home/lazuhyprDotfiles/.config/fastfetch;
      ".config/lsd".source = ../modules/home/lazuhyprDotfiles/.config/lsd;
    };
  };

  # ============================================================================
  # ADDITIONAL USER-SPECIFIC CONFIGURATIONS
  # ============================================================================
  
  # Enable Home Manager for this user (if not already enabled in main config)
  # home-manager.users.${username} = {
  #   imports = [
  #     ../modules/home/profiles/zrrg/default.nix
  #   ];
  # };
  
  # User-specific systemd services
  systemd.user.services = {
    # Example: Auto-start a service for this user
    # my-service = {
    #   Unit.Description = "My user service";
    #   Service.ExecStart = "${pkgs.my-package}/bin/my-command";
    #   Install.WantedBy = [ "default.target" ];
    # };
  };
  
  # User-specific environment variables
  environment.sessionVariables = {
    # Add any user-specific environment variables here
    # EDITOR = "nvim";
    # BROWSER = "firefox";
  };
} 
