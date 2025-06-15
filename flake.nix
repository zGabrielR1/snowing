# flake.nix
{
  description = "My configs (Refactored with flake-parts)";

  inputs = {
    # --- Core ---
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Snaps? why?
    #nix-snapd.url = "github:nix-community/nix-snapd";
    #nix-snapd.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default-linux";

    # --- Theming ---
    nix-colors.url = "github:misterio77/nix-colors";
    matugen.url = "github:InioX/matugen";

    # --- Hyprland Ecosystem ---
    #hyprland = {
    #  url = "github:hyprwm/Hyprland?";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    hyprlock.url = "github:hyprwm/hyprlock";
    hypridle.url = "github:hyprwm/hypridle";
    #hyprland-plugins = {
    #  url = "github:hyprwm/hyprland-plugins";
    #  inputs.hyprland.follows = "hyprland";
    #};
    #hyprspace = {
    #  url = "github:KZDKM/Hyprspace";
    #  inputs.hyprland.follows = "hyprland";
    #};
    mcmojave-hyprcursor.url = "github:libadoxon/mcmojave-hyprcursor";

    # --- Niri ---
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Bars / Launchers / Widgets ---
    #ags.url = "github:Aylur/ags/v1";
    #anyrun.url = "github:fufexan/anyrun/launch-prefix";

    # --- Utilities / Libraries ---
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
    };
    lanzaboote.url = "github:nix-community/lanzaboote";
    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

    # --- Windsurf IDE ---
    windsurf = {
      url = "path:./pkgs/windsurf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Compatibility ---
    flake-compat.url = "github:edolstra/flake-compat";

    # --- Community Repos ---
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, flake-parts, chaotic, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem = { config, pkgs, system, lib, ... }: {
        # Example: Expose custom font packages if they are defined locally
        # packages = {
        #   SF-Pro = pkgs.callPackage ./pkgs/fonts/sf-pro.nix {};
        #   SF-Pro-mono = pkgs.callPackage ./pkgs/fonts/sf-pro-mono.nix {};
        # };
        # For now, assuming SF fonts are handled differently or placeholder
        
        # Expose Windsurf package
        packages = {
          windsurf = inputs.windsurf.packages.${system}.windsurf;
        };
      };
      flake = {
        # NixOS Configurations
        nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; }; # Pass all inputs and self
          modules = [
            # Core Modules
            home-manager.nixosModules.home-manager
            home-manager.nixosModules.home-manager
              {
              home-manager.useGlobalPkgs = true;
              home-manager.backupFileExtension = "HMBackup";
              home-manager.useUserPackages = true;
              #home-manager.users.quiet.imports = [
              #  ./home.nix
              #  catppuccin.homeManagerModules.catppuccin
              #];
            }
            chaotic.nixosModules.default # Chaotic Nyx Module

            # Custom NixOS Modules (Import the top-level module directly)
            ./modules/nixos/default.nix # This should import nix-settings.nix among others

            # Host specific config
            ./hosts/laptop/configuration.nix

            # Hyprland Module (if needed system-wide for XDG portals etc.)
            #inputs.hyprland.nixosModules.default

            # Niri module (if you plan to use Niri system-wide for portals etc.)
            # inputs.niri.nixosModules.niri # Or .default, check niri-flake docs

            # Note: home-manager.useGlobalPkgs and useUserPackages are deprecated
            # and removed. Configuration happens in home-manager.users.<name>
          ];
        };
        # Add other hosts here if needed
        # "desktop" = nixpkgs.lib.nixosSystem { ... };

        # Expose Home Manager modules if you want to reference them like self.homeManagerModules.myProfile
        # homeManagerModules.zrrgBase = ./modules/home/profiles/zrrg/default.nix;
        # homeManagerModules.zrrgHyprland = ./modules/home/profiles/zrrg/wm/hyprland/default.nix;
      };
    };
}
