# modules/home/profiles/zrrg/default.nix
{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./home.nix # Common settings for zrrg
    ./wm/hyprland/default.nix # Hyprland specific settings
    inputs.zen-browser.homeModules.beta

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

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
      save = 10000;
    };
    # Source the dotfiles zshrc
    initContent = ''
      # Source the dotfiles zshrc
      if [ -f ${config.home.homeDirectory}/.zshrc ]; then
        source ${config.home.homeDirectory}/.zshrc
      fi
    '';
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    shortcut = "\\";
    baseIndex = 1;
    escapeTime = 10;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    # The tmux config will be sourced from the dotfiles
  };

  /*
  # GTK configuration
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
  */
  # XDG configuration
  xdg = {
    enable = true;
    configFile = {
      # Source dotfiles configs
      "zshrc".source = ./lazuhyprDotfiles/.config/zshrc;
      "hypr".source = ./lazuhyprDotfiles/.config/hypr;
      "waybar".source = ./lazuhyprDotfiles/.config/waybar;
      "rofi".source = ./lazuhyprDotfiles/.config/rofi;
      "swaync".source = ./lazuhyprDotfiles/.config/swaync;
      "wlogout".source = ./lazuhyprDotfiles/.config/wlogout;
      "wezterm".source = ./lazuhyprDotfiles/.config/wezterm;
      "btop".source = ./lazuhyprDotfiles/.config/btop;
      "lf".source = ./lazuhyprDotfiles/.config/lf;
      "ctpv".source = ./lazuhyprDotfiles/.config/ctpv;
      "mpv".source = ./lazuhyprDotfiles/.config/mpv;
      "fastfetch".source = ./lazuhyprDotfiles/.config/fastfetch;
      "lsd".source = ./lazuhyprDotfiles/.config/lsd;
      "spicetify".source = ./lazuhyprDotfiles/.config/spicetify;
      "nvim".source = ./lazuhyprDotfiles/.config/nvim;
      "ohmyposh".source = ./lazuhyprDotfiles/.config/ohmyposh;
      "fish".source = ./lazuhyprDotfiles/.config/fish;
      "bashrc".source = ./lazuhyprDotfiles/.config/bashrc;
    };
  };

  # Home files (dotfiles in home directory)
  home.file = {
    ".zshrc".source = ./lazuhyprDotfiles/.zshrc;
    ".tmux.conf".source = ./lazuhyprDotfiles/.tmux.conf;
    ".vimrc".source = ./lazuhyprDotfiles/.vimrc;
    ".bashrc".source = ./lazuhyprDotfiles/.bashrc;
    ".gtkrc-2.0".source = ./lazuhyprDotfiles/.gtkrc-2.0;
    ".Xresources".source = ./lazuhyprDotfiles/.Xresources;
    ".ideavimrc".source = ./lazuhyprDotfiles/.ideavimrc;
    ".delta-themes.gitconfig".source = ./lazuhyprDotfiles/.delta-themes.gitconfig;
    ".stow-local-ignore".source = ./lazuhyprDotfiles/.stow-local-ignore;
  };

  # Example: Starship prompt
  programs.starship = {
    enable = true;
    # settings = { ... };
  };

  # Fontconfig (user-specific overrides/additions if needed)
  fonts.fontconfig.enable = true;
}
