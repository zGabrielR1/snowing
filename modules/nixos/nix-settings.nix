# modules/nixos/nix-settings.nix
{ config, lib, pkgs, inputs, ... }:

let
  flakeInputs = lib.filterAttrs (_: v: builtins.isAttrs v && v.type == "flake") inputs;
  autoGarbageCollector = config.var.autoGarbageCollector or false;
in
{
  # For flakes
  # Essential packages for flakes
  environment.systemPackages = with pkgs; [ 
    git 
    curl
    wget
    nix-output-monitor # Better build output
    nvd # Nix version diff tool
  ];

  # Sudo rules for nixos-rebuild
  # Safer: grant NOPASSWD to user zrrg when present
  security.sudo.extraRules = lib.mkIf (config.users.users ? "zrrg") [{
    users = [ "zrrg" ];
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
  # nixpkgs configuration
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true; # Changed from true for stability
    allowInsecure = false;
    allowUnsupportedSystem = false;
  };

  # Faster rebuilding - optimized documentation settings
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

    #Registry configuration - pin flake inputs
    registry = lib.mapAttrs (_key: flake: { inherit flake; }) (
      lib.filterAttrs (_key: value: value ? outputs) flakeInputs
    );

    # Nix path for legacy compatibility
    nixPath = lib.mapAttrsToList (key: _value: "${key}=flake:${key}") flakeInputs;


    # Extra options - optimized for speed
    extraOptions = ''
      warn-dirty = false
      max-jobs = auto
      cores = 0
    '';

    settings = {
      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://zgabrielr.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://divnix.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://chaotic-nyx.cachix.org"
        "https://colmena.cachix.org"
        "https://anyrun.cachix.org"
        "https://niri.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "zgabrielr.cachix.org-1:DNsXs3NCf3sVwby1O2EMD5Ai/uu1Z1uswKSh47A1mvw="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "divnix.cachix.org-1:U8QPQF411uJGX3mW9E1ojuFu6QLJrrUETcOEjBuBYHg="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      ];

      # Performance optimizations
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      trusted-users = [ "root" "@wheel" "zrrg" ];
      accept-flake-config = true;

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

    # Optimized garbage collection settings
    gc = {
      automatic = autoGarbageCollector;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
