# modules/home/profiles/zrrg/home.nix
# Base settings for user zrrg
{ config, pkgs, system, inputs, ... }:
{
  home.username = "zrrg";
  home.homeDirectory = "/home/zrrg";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    #inputs.zen-browser.packages."${system}".specific
    zip
    xz
    unzip
    p7zip
    oh-my-zsh
    oh-my-posh
    # Example: custom flake input package
    # inputs.zen-browser.packages."${system}".specific
    hyprpaper
    waybar
    dunst
    wofi
    wl-clipboard
    slurp
    grim
    swappy
    brightnessctl
    pavucontrol
    networkmanagerapplet
    polkit_gnome
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
  ];

  # Shell aliases
  home.shellAliases = {
    ll = "ls -l";
    update = "nh os switch --flake ~/Dev/nixland";
  };

  # GTK Theming
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 11;
    };
    # theme.name = "Adwaita-dark";
    # iconTheme.name = "Papirus-Dark";
    # cursorTheme.name = "McMojave-cursors";
  };

  # Catppuccin theming
  /*catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };
  */

  # Git configuration
  programs.git = {
    enable = true;
    userName = "notquitethereyet";
    userEmail = "example@example.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # Home Manager manages itself
  programs.home-manager.enable = true;

  # Home Manager state version
  home.stateVersion = "25.11";
}
