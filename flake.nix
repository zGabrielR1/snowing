# flake.nix
{
  description = "My NixOS configurations with flake-parts";

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

    # --- Applications ---
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Optional Inputs (uncomment as needed) ---
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nix-colors.url = "github:misterio77/nix-colors";
    # agenix = {
    #   url = "github:ryantm/agenix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager.follows = "home-manager";
    # };
  };

  outputs = { self, nixpkgs, home-manager, flake-parts, chaotic, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      
      perSystem = { config, pkgs, system, lib, ... }: {
        # Custom packages
        packages = {
          # Add custom packages here
          # windsurf = inputs.windsurf.packages.${system}.windsurf or null;
        };
        
        # Development shells
        devShells = {
          default = pkgs.mkShell {
            name = "nixos-config";
            buildInputs = with pkgs; [
              nixpkgs-fmt
              statix
              deadnix
              alejandra
              nil # Nix LSP
              nix-tree # Dependency visualization
            ];
            shellHook = ''
              echo "🔧 NixOS Configuration Development Shell"
              echo "Available tools: nixpkgs-fmt, statix, deadnix, alejandra, nil, nix-tree"
            '';
          };
          
          # Specialized shell for system administration
          admin = pkgs.mkShell {
            name = "nixos-admin";
            buildInputs = with pkgs; [
              nixos-rebuild
              home-manager
              git
              vim
              htop
            ];
            shellHook = ''
              echo "🛠️  NixOS Administration Shell"
              echo "Quick commands:"
              echo "  rebuild-switch: sudo nixos-rebuild switch --flake .#laptop"
              echo "  rebuild-test: sudo nixos-rebuild test --flake .#laptop"
              echo "  home-switch: home-manager switch --flake .#zrrg"
            '';
          };
        };
        
        # Formatters
        formatter = pkgs.alejandra;
      };
      
      flake = {
        # NixOS Configurations
        nixosConfigurations = {
          laptop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { 
              inherit inputs self; 
              users = ["zrrg"];
            };
            modules = [
              # Core modules
              home-manager.nixosModules.home-manager
              chaotic.nixosModules.default
              
              # Custom modules
              ./modules/nixos
              
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
              }
            ];
          };
        };
        
        # Home Manager Configurations (standalone)
        homeConfigurations = {
          zrrg = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
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
