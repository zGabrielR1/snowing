# modules/home/profiles/zrrg/default.nix
# This is the entry point for the 'zrrg' user profile.
# It imports all the necessary modules for this user's configuration.
{ ... }:

{
  imports = [
    # Main home configuration
    ./home.nix
    
    # Window manager configuration
    ./wm/hyprland/default.nix
    
    # You can add more specific modules here:
    # ./development.nix
    # ./gaming.nix
    # ./multimedia.nix
    # ./productivity.nix
  ];
}