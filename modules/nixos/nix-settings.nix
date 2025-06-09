# modules/nixos/nix-settings.nix
{ config, lib, pkgs, inputs, ... }:

let
  flakeInputs = lib.filterAttrs (_: v: builtins.isAttrs v && v.type == "flake") inputs;
  autoGarbageCollector = config.var.autoGarbageCollector or false;
in
{
  # For flakes
  environment.systemPackages = [ pkgs.git ];

  # Sudo rules for nixos-rebuild
  security.sudo.extraRules = lib.mkIf (config.users.users ? ${config.users.users.mainUser or "root"}) [{
    users = [ config.users.users.mainUser or "root" ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  # nh configuration
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d";
    };
  };

  # nixpkgs configuration
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  # Faster rebuilding - optimized documentation settings
  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  nix = {
    package = lib.mkDefault pkgs.nix;

    # Registry configuration
    registry = lib.mapAttrs (_key: flake: { inherit flake; }) (
      lib.filterAttrs (name: _: name != "self" && inputs ? ${name} && inputs.${name} ? type && inputs.${name}.type == "flake") inputs
    );

    # Set the path for channels compat
    nixPath = lib.mapAttrsToList (key: value: "${key}=flake:${key}") config.nix.registry;

    # Extra options - optimized for speed
    extraOptions = ''
      warn-dirty = false
      # Performance optimizations
      max-jobs = auto
      cores = 0
      # Faster evaluation
      eval-cache = true
      # Reduce memory usage
      gc-reserved-space = 1G
      # Optimize for speed over space
      min-free = 1G
      max-free = 5G
      # Faster store operations
      fsync-metadata = false
      # Optimize for parallel builds
      build-max-jobs = auto
      # Reduce network overhead
      http-connections = 50
      # Optimize for local builds
      builders-use-substitutes = true
      # Faster garbage collection
      gc-keep-derivations = true
      gc-keep-outputs = true
      # Optimize for flakes
      accept-flake-config = true
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
        "https://nix-gaming.cachix.org"
        "https://colmena.cachix.org"
        "https://nrdxp.cachix.org"
        "https://anyrun.cachix.org"
        "https://fufexan.cachix.org"
        "https://helix.cachix.org"
        "https://niri.cachix.org"
        # Additional high-performance caches
        "https://cache.ngi0.nixos.org"
        "https://nixpkgs-update.cachix.org"
        "https://mic92.cachix.org"
        "https://ryantm.cachix.org"
        "https://dram.cachix.org"
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
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        # Additional cache keys
        "cache.ngi0.nixos.org-1:q8R2Ba8C+dm6NqzQS+bB1Ww8j7oFQ/Yb7b5LpDb5QYw="
        "nixpkgs-update.cachix.org-1:6y6Z+JpovGm7X66o6dQfrLwDGj0qXe4b3X5wJ8L5VYI="
        "mic92.cachix.org-1:j1faOshT0cC2mu8ujyxw1O9Pq8cN1+QvtAbj5V14tks="
        "ryantm.cachix.org-1:diX/183g5WLj8PJFKkXx+NKZXJfLJCjU0hqXe6zBzKc="
        "dram.cachix.org-1:3RuPzdxQmXxJqSkoJr77yQcTEP8iFJ+0HqK0Hh7VK1E="
      ];

      # Performance optimizations
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = [ "nix-command" "flakes" "ca-derivations" "recursive-nix" ];
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      # Performance-focused settings
      max-jobs = "auto";
      cores = 0;
      build-max-jobs = "auto";
      
      # Memory and storage optimizations
      gc-reserved-space = "1G";
      min-free = "1G";
      max-free = "5G";
      
      # Network optimizations
      http-connections = 50;
      
      # Store optimizations
      fsync-metadata = false;
      
      # Evaluation optimizations
      eval-cache = true;
      
      # System features for better performance
      system-features = [ "kvm" "big-parallel" "nixos-test" "recursive-nix" ];

      trusted-users = [ "root" "@wheel" "zrrg" ];
      accept-flake-config = true;
    };

    # Optimized garbage collection settings
    gc = {
      automatic = autoGarbageCollector;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d --max-freed 10G";
    };
  };

  # Additional performance optimizations
  boot = {
    # Faster boot times
    loader.timeout = 1;
    # Optimize kernel parameters for faster rebuilds
    kernelParams = [ 
      "elevator=deadline"
      "i915.enable_rc6=1"
      "i915.enable_fbc=1"
      "i915.lvds_downclock=1"
      "radeon.dpm=1"
      "radeon.audio=1"
      "amdgpu.dpm=1"
      "amdgpu.audio=1"
    ];
  };

  # Optimize systemd for faster rebuilds
  systemd = {
    # Faster service startup
    services.systemd-udev-trigger.enable = false;
    # Optimize for rebuilds
    extraConfig = ''
      DefaultTimeoutStartSec=10s
      DefaultTimeoutStopSec=10s
      DefaultRestartSec=100ms
    '';
  };
}
