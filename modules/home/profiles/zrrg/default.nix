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

  # Enable extra programs and settings not defined in home.nix
  programs.starship = {
    enable = true;
    # settings = { ... };
  };

  programs.zsh = {
    enable = true;
    # ohMyZsh.enable = true; # Example
  };

  # Example: Link dotfiles or set environment variables here if not in home.nix
  # home.file.".config/nvim/init.vim".source = ./config/nvim/init.vim;
  # xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf;
  # home.sessionVariables = {
  #   EDITOR = "nvim";
  # };
  # fonts.fontconfig.enable = true;
}
