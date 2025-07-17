# modules/home/profiles/zrrg/default.nix
# Entry point for the 'zrrg' user profile. Auto-imports all .nix modules in this directory except itself.
{ ... }:
{
  imports = builtins.filter (f: f != ./default.nix)
    (map (n: ./. + "/${n}") (builtins.attrNames (builtins.readDir ./.)));
}