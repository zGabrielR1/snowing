{ config, lib, pkgs, ... }:

{
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://zgabrielr.cachix.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://divnix.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://chaotic.cachix.org"
      "https://determinate.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://colmena.cachix.org"
      "https://nrdxp.cachix.org"
      "https://cache.iog.io"
      "https://anyrun.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "zgabrielr.cachix.org-1:DNsXs3NCf3sVwby1O2EMD5Ai/uu1Z1uswKSh47A1mvw="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiQMmr7/mho7G4ZPo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:53/BlWLgjTTnOEGTBrOsbOWmA5BoTyJkj8eIG3mA0n8="
      "divnix.cachix.org-1:Ek/jazMWxT9v7i1I95Z6lfxyvMZgF3eLnMWajJ2KKZ0="
      "nixpkgs-wayland.cachix.org-1:XJ1a29PyPzUz8W6sEhnOTrF3OSa/6MExNdeyDOvGrmM="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12fFjjJUbTBPoGio="
      "determinate.cachix.org-1:Vv+o9J9Z5Qj5z5Z5Qj5z5Z5Qj5z5Z5Qj5z5Z5Qj5z5Z5="
      "nix-gaming.cachix.org-1:CZhLxF7EvQbKptIUQhKToZFn7P9zEfiGMIkpw8bF1BQ="
      "colmena.cachix.org-1:xqTOfEBeaK3ih3uEvDk2l8az4dfbyODVnC4CvI7vOpM="
      "nrdxp.cachix.org-1:Uqez+I5ZQXzdrgcT3l5bk3Ayv9PAxYOUM4fHZUQQpzA="
      "cache.iog.io-1:2oxmqbypA9RUsaLtqHo/w3U6yymH3js0X9iP2s4r04Q="
      "anyrun.cachix.org-1:ZAVcFQeRvZDOekcVG02/M7ESU2rxFjTtnSIXa2qw7Rg="
    ];

    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
    experimental-features = [ "nix-command" "flakes" ];
  };
}
