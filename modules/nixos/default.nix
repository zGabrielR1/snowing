# modules/nixos/default.nix
# Auto-imports all .nix modules in this directory except itself for easier modularity.
{ ... }:
{
  imports = builtins.filter (f: f != ./default.nix)
    (map (n: ./. + "/${n}") (builtins.attrNames (builtins.readDir ./.)));
}
