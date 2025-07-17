# modules/home/profiles/zrrg/default.nix
# Entry point for the 'zrrg' user profile. Auto-imports all .nix modules in this directory except itself.
{ ... }:
{
  imports = 
    let
      isNixFile = name: builtins.match ".*\\.nix$" name != null && name != "default.nix";
      files = builtins.attrNames (builtins.readDir ./.);
    in
      map (n: ./. + "/${n}") (builtins.filter isNixFile files);
}