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
        "https://zgabrielr.cachix.org" # Your cache
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://divnix.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://chaotic.cachix.org" # chaotic-nyx is the new name for chaotic.cachix.org
        "https://determinate.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://colmena.cachix.org"
        "https://nrdxp.cachix.org"
        "https://cache.iog.io"
        "https://anyrun.cachix.org"
        # Add fufexan, helix, niri if you use their packages often
        "https://fufexan.cachix.org"
        "https://helix.cachix.org"
        "https://niri.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "zgabrielr.cachix.org-1:DNsXs3NCf3sVwby1O2EMD5Ai/uu1Z1uswKSh47A1mvw="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiQMmr7/mho7G4ZPo="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:53/BlWLgjTTnOEGTBrOsbOWmA5BoTyJkj8eIG3mA0n8="
        "divnix.cachix.org-1:Ek/jazMWxT9v7i1I95Z6lfxyvMZgF3eLnMWajJ2KKZ0="
        "nixpkgs-wayland.cachix.org-1:XJ1a29PyPzUz8W6sEhnOTrF3OSa/6MExNdeyDOvGrmM="
        "chaotic.cachix.org-1:7BQr63cvB12KRgf8k3sLJN2LHaHToTz7kF9AU7AmwL8=" # Key for chaotic.cachix.org (new)
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12fFjjJUbTBPoGio=" # Key for chaotic-nyx.cachix.org (legacy if still needed)
        "determinate.cachix.org-1:Vv+o9J9Z5Qj5z5Z5Qj5z5Z5Qj5z5Z5Qj5z5Z5Qj5z5Z5="
        "nix-gaming.cachix.org-1:CZhLxF7EvQbKptIUQhKToZFn7P9zEfiGMIkpw8bF1BQ=" # Current nix-gaming key
        # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" # Older key, check which one is active
        "colmena.cachix.org-1:xqTOfEBeaK3ih3uEvDk2l8az4dfbyODVnC4CvI7vOpM="
        "nrdxp.cachix.org-1:Uqez+I5ZQXzdrgcT3l5bk3Ayv9PAxYOUM4fHZUQQpzA="
        "cache.iog.io-1:2oxmqbypA9RUsaLtqHo/w3U6yymH3js0X9iP2s4r04Q="
        "anyrun.cachix.org-1:ZAVcFQeRvZDOekcVG02/M7ESU2rxFjTtnSIXa2qw7Rg="
        # Add keys for fufexan, helix, niri if you added their caches
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
