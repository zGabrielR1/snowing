{
  description = "My configs";

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
    # Snaps? why?
    #nix-snapd.url = "github:nix-community/nix-snapd";
    #nix-snapd.inputs.nixpkgs.follows = "nixpkgs";
    # NOTE: Previously used flake-parts; removed as unnecessary

    # --- Dotfile Management ---
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Theming ---
    #nix-colors.url = "github:misterio77/nix-colors";
    # matugen.url = "github:InioX/matugen";

    # --- Hyprland Ecosystem ---
    #hyprland = {
    #  url = "github:hyprwm/Hyprland?";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    #hyprlock.url = "github:hyprwm/hyprlock";
    #hypridle.url = "github:hyprwm/hypridle";
    #hyprland-plugins = {
    #  url = "github:hyprwm/hyprland-plugins";
    #  inputs.hyprland.follows = "hyprland";
    #};
    #hyprspace = {
    #  url = "github:KZDKM/Hyprspace";
    #  inputs.hyprland.follows = "hyprland";
    #};


    # --- Bars / Launchers / Widgets ---
    #ags.url = "github:Aylur/ags/v1";
    #anyrun.url = "github:fufexan/anyrun/launch-prefix";

    # --- Utilities / Libraries ---
    /*
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    */
    #lanzaboote.url = "github:nix-community/lanzaboote";
    # nix-index-db = {
    #   url = "github:Mic92/nix-index-database";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    /*
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    */
    # nix-ld = {
    #   url = "github:Mic92/nix-ld";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };



    # --- Compatibility ---
    #flake-compat.url = "github:edolstra/flake-compat";

    # --- Community Repos ---
    #nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, chaotic, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # Per-system development shells
      devShells = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          name = "nixos-config-dev";
          buildInputs = with pkgs; [
            # Nix formatting and linting
            nixpkgs-fmt
            statix
            deadnix
            alejandra
            nil

            # Development utilities
            nix-tree
            nix-diff
            nix-output-monitor
            nh # Yet another nix helper

            # System utilities
            git
            jq
            yq
            ripgrep
          ];

          shellHook = ''
            echo "🚀 NixOS Configuration Development Shell"
            echo "Available tools:"
            echo "  Formatting: nixpkgs-fmt, alejandra"
            echo "  Linting: statix, deadnix, nil"
            echo "  Analysis: nix-tree, nix-diff, nix-output-monitor"
            echo "  Utilities: nh, jq, yq, ripgrep"
            echo ""
            echo "Quick commands:"
            echo "  nh os switch    - Build and switch to new config"
            echo "  nh os test      - Test configuration"
            echo "  nh clean all    - Clean up old generations"
          '';
        };
      });

      # Per-system formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # NixOS Configurations
      nixosConfigurations = {
        # Main laptop configuration
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs self;
            users = [ "zrrg" ];
          };

          modules = [
            # Core modules
            home-manager.nixosModules.home-manager
            chaotic.nixosModules.default

            # Custom NixOS modules (auto-imports all .nix files via default.nix)
            ./modules/nixos

            # User configurations
            ./users

            # Host configuration
            ./hosts/laptop/configuration.nix

            # Home Manager integration
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "HMBackup";
                extraSpecialArgs = { inherit inputs; };

                # Import user-specific home-manager configuration
                users.zrrg = { config, pkgs, lib, ... }:
                  import ./modules/home/profiles/zrrg { inherit config pkgs lib inputs; };
              };

              # Platform configuration
              nixpkgs.hostPlatform = "x86_64-linux";
            }
          ];
        };
        
        # Desktop configuration with manual module imports
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs self;
            users = [ "zrrg" ];
          };

          modules = [
            # Core modules
            home-manager.nixosModules.home-manager
            chaotic.nixosModules.default

            # Manually import only the modules we want for desktop
            # Core system modules
            ./modules/nixos/default.nix     # Snowing configuration system
            ./modules/nixos/packages.nix    # System packages
            ./modules/nixos/services.nix    # System services
            ./modules/nixos/nix-settings.nix # Nix settings
            ./modules/nixos/locale.nix      # Localization
            ./modules/nixos/networking.nix  # Basic networking
            ./modules/nixos/audio.nix       # Audio support
            ./modules/nixos/bluetooth.nix   # Bluetooth support
            ./modules/nixos/fonts.nix       # Fonts
            ./modules/nixos/utils.nix       # Utility functions
            
            # User configurations
            ./users

            # Host configuration
            ./hosts/desktop/configuration.nix

            # Home Manager integration
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "HMBackup";
                extraSpecialArgs = { inherit inputs; };

                # Import user-specific home-manager configuration
                users.zrrg = { config, pkgs, lib, ... }:
                  import ./modules/home/profiles/zrrg { inherit config pkgs lib inputs; };
              };

              # Platform configuration
              nixpkgs.hostPlatform = "x86_64-linux";
            }
          ];
        };
      };

      # Home Manager Configurations (standalone)
      homeConfigurations = {
        # Standalone home-manager configuration for user 'zrrg'
        zrrg = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };

          modules = [
            # Import user-specific home-manager modules
            ./modules/home/profiles/zrrg
          ];
        };
      };

      # Templates for creating new configurations
      templates = {
        # Template for new NixOS host configurations
        nixos-host = {
          path = ./templates/nixos-host;
          description = "Template for creating a new NixOS host configuration with standard modules";
        };
        home-user = {
          path = ./templates/home-user;
          description = "Template for creating a new Home Manager user configuration";
        };
      };
    };
}
