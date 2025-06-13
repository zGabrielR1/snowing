{
  description = "Windsurf - Agentic IDE powered by AI Flow paradigm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          windsurf = pkgs.callPackage ./package.nix { };
        };
        
        apps = {
          windsurf = {
            type = "app";
            program = "${self.packages.${system}.windsurf}/bin/windsurf";
          };
        };
      }
    );
} 