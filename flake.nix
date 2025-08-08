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

    # --- Windsurf IDE ---
    #windsurf = {
    #  url = "path:./pkgs/windsurf";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    # --- Compatibility ---
    #flake-compat.url = "github:edolstra/flake-compat";

    # --- Community Repos ---
    #nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, chaotic, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
    in
    {
      # Per-system packages
      packages = forAllSystems (system: let
        pkgs = nixpkgsFor.${system};
      in {
        # Add custom packages here, e.g. myPkg = pkgs.callPackage ...;
      });

      # Per-system development shells
      devShells = forAllSystems (system: let
        pkgs = nixpkgsFor.${system};
      in {
        default = pkgs.mkShell {
          name = "nixos-config";
          buildInputs = with pkgs; [
            nixpkgs-fmt
            statix
            deadnix
            alejandra
            nil
            nix-tree
          ];
          shellHook = ''
            echo "🔧 NixOS Configuration Development Shell"
            echo "Available tools: nixpkgs-fmt, statix, deadnix, alejandra, nil, nix-tree"
          '';
        };
      });

      # Per-system formatter
      formatter = forAllSystems (system: let
        pkgs = nixpkgsFor.${system};
      in pkgs.alejandra);

      # NixOS Configurations
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs self;
            pkgs = nixpkgsFor.x86_64-linux;
            users = [ "zrrg" ];
          };
          modules = [
            # Core modules
            home-manager.nixosModules.home-manager
            chaotic.nixosModules.default

            # Custom modules
            ./modules/nixos

            # Users configuration
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
                users.zrrg = import ./modules/home/profiles/zrrg;
              };

              # Ensure system is properly set
              nixpkgs.hostPlatform = "x86_64-linux";
            }
          ];
        };
      };

      # Home Manager Configurations (standalone)
      homeConfigurations = {
        zrrg = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./modules/home/profiles/zrrg
          ];
        };
      };

      # Templates for creating new configurations
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
