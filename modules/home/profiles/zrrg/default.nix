# modules/home/profiles/zrrg/default.nix
{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./home.nix # Common settings for zrrg
    ./wm/hyprland/default.nix # Hyprland specific settings

    # Other components
    # ./cli-tools.nix
    # ./dev-tools.nix

    inputs.nix-index-db.hmModules.nix-index # For nix-index
    # For theming, you'd typically define color schemes and apply them, not import NixOS modules
    # e.g., inputs.nix-colors.homeManagerModules.default if you use nix-colors
  ];

  # Enable programs
  programs.git.enable = true;
  programs.home-manager.enable = true; # Good practice

  # Example: Starship prompt
  programs.starship = {
    enable = true;
    # settings = { ... };
  };

  # Basic shell setup
  programs.zsh = { # Or bash
    enable = true;
    # ohMyZsh.enable = true; # Example
  };

  # Link dotfiles
  # home.file.".config/nvim/init.vim".source = ./config/nvim/init.vim;
  # Or use xdg.configFile for better organization
  #xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf; # Example path

  # Environment variables
  # home.sessionVariables = {
  #   EDITOR = "nvim";
  # };

  # Fontconfig (user-specific overrides/additions if needed)
  # fonts.fontconfig.enable = true;
}
