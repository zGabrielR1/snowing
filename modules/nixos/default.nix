# modules/nixos/default.nix
# Auto-imports all .nix modules in this directory except itself for easier modularity.
{ ... }:
{
  imports = 
  let
    isNixFile = name: builtins.match ".*\\.nix$" name != null && name != "default.nix";
    files = builtins.attrNames (builtins.readDir ./.);
  in
    map (n: ./. + "/${n}") (builtins.filter isNixFile files);
}
