# modules/nixos/default.nix
# Auto-imports all .nix modules in this directory except itself for easier modularity.
{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption;
  inherit (lib.types) listOf str;
  
  isNixFile = name: builtins.match ".*\\.nix$" name != null && name != "default.nix";
  files = builtins.attrNames (builtins.readDir ./.);
in
{
  imports = map (n: ./. + "/${n}") (builtins.filter isNixFile files);
  
  options = {
    # Snowing configuration system
    snowing = {
      # Data options used across modules
      data = {
        users = mkOption {
          type = listOf str;
          default = [];
          description = "List of users for the system";
        };
        headless = mkEnableOption "headless system";
      };
      
      # Program options
      programs = {
        # wine options moved to wine.nix; keep empty stub to avoid duplicates
        wine = { };  # defines moved to wine.nix
      };
      
      
      
      # Graphics options
      graphics = {
        enable = mkEnableOption "graphics";
        intel.enable = mkEnableOption "intel graphics";
        nvidia.enable = mkEnableOption "nvidia graphics";
        amd.enable = mkEnableOption "amd graphics";
      };
    };
  };
}
