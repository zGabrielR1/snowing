# modules/home/default.nix
{ inputs, ... }:

{
  # This file acts as the entry point for home-manager modules.
  # It should return an attribute set where keys are module names
  # and values are the module files or attribute sets.

  # Import the currently selected user profile/wm config.
  # Based on the original flake.nix, aura.nix was active.
  # The NixOS configuration should import `self.homeModules.default.aura`.
  zrrg = import ./profiles/zrrg/wm/hyprland/default.nix;

  # If you had a base user configuration like ./profiles/zrrg/home.nix,
  # you would import it here as well:
  # base = import ./profiles/zrrg/home.nix;
  # And the NixOS configuration would import `self.homeModules.default.base`.
}
