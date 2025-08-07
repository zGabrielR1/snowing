{
  description = "My configs (Refactored with flake-parts)";

  inputs = {
    # --- Core Inputs ---
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # --- Dotfile Management ---
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Utilities / Packages ---
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, flake-parts, chaotic, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Target systems this flake should evaluate for
      systems = [ "x86_64-linux" ];

      ### Per-system config ###
      perSystem = { config, pkgs, system, lib, ... }: {
        # Custom packages (currently empty)
        packages = { };

        # Development shell
        devShells.default = pkgs.mkShell {
          name = "nixos-config";
          buildInputs = with pkgs; [
            nixpkgs-fmt
            statix
            deadnix
            alejandra
            nil         # Nix LSP
            nix-tree    # Dependency visualization
          ];
          shellHook = ''
            echo "🔧 NixOS Configuration Development Shell"
            echo "Available tools: nixpkgs-fmt, statix, deadnix, alejandra, nil, nix-tree"
          '';
        };

        # Formatter for `nix fmt`
        formatter = pkgs.alejandra;
      };

      ### Global flake outputs ###
      flake = {
        # NixOS configurations
        nixosConfigurations = {
          laptop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs self;
              users = [ "zrrg" ];
            };
            modules = [
              home-manager.nixosModules.home-manager
              chaotic.nixosModules.default
              ./modules/nixos
              ./users
              ./hosts/laptop/configuration.nix
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "HMBackup";
                  extraSpecialArgs = { inherit inputs; };
                  users.zrrg = import ./modules/home/profiles/zrrg;
                };
              }
            ];
          };
        };

        # Home Manager standalone configs
        homeConfigurations = {
          zrrg = let
            system = "x86_64-linux";
          in home-manager.lib.homeManagerConfiguration {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
            extraSpecialArgs = { inherit inputs; };
            modules = [
              ./modules/home/profiles/zrrg
            ];
          };
        };

        # Templates for new configs
        templates = {
          nixos-host = {
            path = ./templates/nixos-host;
            description = "Template for a new NixOS host configuration";
          };
          home-user = {
            path = ./templates/home-user;
            description = "Template for a new Home Manager user configuration";
          };
        };
      };
    };
}
