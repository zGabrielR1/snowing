# modules/nixos/nix-settings.nix
{ config, lib, pkgs, inputs, ... }:

let
  flakeInputs = lib.filterAttrs (_: v: builtins.isAttrs v && v ? type && v.type == "flake") inputs;
  autoGarbageCollector = config.var.autoGarbageCollector or false;
in
{
  # Essential packages for flakes
  environment.systemPackages = with pkgs; [ 
    git 
    curl
    wget
    nix-output-monitor # Better build output
    nvd # Nix version diff tool
  ];

  # Sudo rules for nixos-rebuild
  security.sudo.extraRules = lib.mkIf (config.users.users ? ${config.users.users.mainUser or "root"}) [{
    users = [ config.users.users.mainUser or "root" ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  # nh configuration - modern Nix helper
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "/etc/nixos"; # Adjust path as needed
  };

  # nixpkgs configuration
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false; # Changed from true for stability
    allowInsecure = false;
    allowUnsupportedSystem = false;
  };

  # Optimized documentation settings for faster rebuilding
  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    man.generateCaches = true;
    dev.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  nix = {
    package = lib.mkDefault pkgs.nix;

    # Registry configuration - pin flake inputs
    registry = lib.mapAttrs (_key: flake: { inherit flake; }) (
      lib.filterAttrs (_key: value: value ? outputs) flakeInputs
    );

    # Nix path for legacy compatibility
    nixPath = lib.mapAttrsToList (key: _value: "${key}=flake:${key}") flakeInputs;

    # Channel configuration
    channel.enable = false; # We use flakes exclusively

    # Performance and build settings
    settings = {
      # Build settings
      max-jobs = "auto";
      cores = 0; # Use all available cores
      
      # Experimental features
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "recursive-nix"
      ];
      
      # Substituters and caches
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://chaotic-nyx.cachix.org/"
      ];
      
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      ];

      # Trust settings
      trusted-users = [ "root" "@wheel" ];
      allowed-users = [ "@wheel" ];

      # Build optimization
      builders-use-substitutes = true;
      substitute-on-destination = false;
      
      # Sandbox settings
      sandbox = true;
      sandbox-fallback = false;
      
      # Keep outputs and derivations for development
      keep-outputs = true;
      keep-derivations = true;
      
      # Auto-optimize store
      auto-optimise-store = true;
      
      # Warn about dirty Git trees
      warn-dirty = false;
      
      # Network settings
      connect-timeout = 5;
      stalled-download-timeout = 300;
      
      # Build log settings
      log-lines = 25;
      
      # Allow import from derivation (needed for some packages)
      allow-import-from-derivation = true;
      
      # Netrc file for private repositories
      netrc-file = "/etc/nix/netrc";
    };

    # Garbage collection
    gc = {
      automatic = lib.mkDefault autoGarbageCollector;
      dates = "weekly";
      options = "--delete-older-than 7d";
      persistent = true;
    };

    # Automatic store optimization
    optimise = {
      automatic = true;
      dates = [ "03:45" ]; # Run at 3:45 AM
    };

    # Distributed builds (if you have multiple machines)
    # buildMachines = [];
    # distributedBuilds = true;
  };

  # System-wide environment variables
  environment.variables = {
    # Nix-specific variables
    NIX_PATH = lib.mkForce "nixpkgs=flake:nixpkgs";
    
    # Editor for nix edit
    EDITOR = lib.mkDefault "vim";
    
    # Pager settings
    PAGER = lib.mkDefault "less -R";
    LESS = lib.mkDefault "-R";
  };

  # Systemd service for automatic store optimization
  systemd.services.nix-optimise = {
    description = "Nix Store Optimiser";
    # Use the timer instead of running directly
    enable = false;
  };

  systemd.timers.nix-optimise = {
    description = "Nix Store Optimiser Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:45";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  # Additional system tweaks for Nix performance
  boot.kernel.sysctl = {
    # Increase file descriptor limits for large builds
    "fs.file-max" = 2097152;
    "fs.nr_open" = 1048576;
  };

  # Increase limits for Nix builds
  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576:1048576
  '';

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];
}
