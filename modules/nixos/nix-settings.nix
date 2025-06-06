# modules/nixos/nix-settings.nix
{ config, lib, pkgs, inputs, ... }:

{
  # For flakes
  environment.systemPackages = [ pkgs.git ];

  nix = let
    flakeInputs = lib.filterAttrs (_: v: builtins.isAttrs v && v ? type && v.type == "flake") inputs;
  in {
    package = lib.mkDefault pkgs.nix; # Or pkgs.lix if you strongly prefer it and it's stable enough for you

    # Pin the registry to avoid downloading and evaling a new nixpkgs version every time
    # registry = lib.mapAttrs (_: v: { flake = v; }) flakeInputs;
    # A more robust way to handle registry for inputs available in 'inputs':
    registry = lib.mapAttrs (_key: flake: { inherit flake; }) (
      lib.filterAttrs (name: _: name != "self" && inputs ? ${name} && inputs.${name} ? type && inputs.${name}.type == "flake") inputs
    );


    # Set the path for channels compat
    nixPath = lib.mapAttrsToList (key: value: "${key}=flake:${key}") config.nix.registry;

    settings = {
      substituters = [
        "https://cache.nixos.org/"
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
      ];

      auto-optimise-store = true;
      builders-use-substitutes = true; # Already default, but explicit is fine
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "/etc/nix/registry.json"; # This is usually managed by nix itself

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      trusted-users = [ "root" "@wheel" "zrrg" ]; # Add your user for certain operations
      accept-flake-config = true; # Often needed for flakes with system/kernel params
    };
  };
}
