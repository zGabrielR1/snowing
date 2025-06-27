{
  pkgs,
  config,
  outputs,
  lib,
  ...
}: let
  username = "zrrg";
  description = "Gabriel Renostro";
in {
  users.users.${username} = {
    inherit description;
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "incus-admin" "podman" "docker" "multimedia"];
    
    # Common packages for all hosts
    packages = [
      pkgs.git
      pkgs.bat
      pkgs.delta
      pkgs.btop
    ];
  };

  # Hjem configuration for dotfile management
  hjem.users.${username} = {
    enable = true;
    user = username;
    directory = config.users.users.${username}.home;
    clobberFiles = lib.mkForce true;

    files = {
      # Shell configurations
      ".zshrc".source = ../../modules/home/lazuhyprDotfiles/.zshrc;
      ".bashrc".source = ../../modules/home/lazuhyprDotfiles/.bashrc;
      ".config/zshrc".source = ../../modules/home/lazuhyprDotfiles/.config/zshrc;

      # Terminal and editor configurations
      ".tmux.conf".source = ../../modules/home/lazuhyprDotfiles/.tmux.conf;
      ".vimrc".source = ../../modules/home/lazuhyprDotfiles/.vimrc;
      ".ideavimrc".source = ../../modules/home/lazuhyprDotfiles/.ideavimrc;

      # X11 and GTK configurations
      ".gtkrc-2.0".source = ../../modules/home/lazuhyprDotfiles/.gtkrc-2.0;
      ".Xresources".source = ../../modules/home/lazuhyprDotfiles/.Xresources;

      # Git delta themes
      ".delta-themes.gitconfig".source = ../../modules/home/lazuhyprDotfiles/.delta-themes.gitconfig;

      # Stow configuration
      ".stow-local-ignore".source = ../../modules/home/lazuhyprDotfiles/.stow-local-ignore;

      # Application configurations
      ".config/hypr".source = ../../modules/home/lazuhyprDotfiles/.config/hypr;
      ".config/waybar".source = ../../modules/home/lazuhyprDotfiles/.config/waybar;
      ".config/rofi".source = ../../modules/home/lazuhyprDotfiles/.config/rofi;
      ".config/swaync".source = ../../modules/home/lazuhyprDotfiles/.config/swaync;
      ".config/wlogout".source = ../../modules/home/lazuhyprDotfiles/.config/wlogout;
      ".config/wezterm".source = ../../modules/home/lazuhyprDotfiles/.config/wezterm;
      ".config/btop".source = ../../modules/home/lazuhyprDotfiles/.config/btop;
      ".config/lf".source = ../../modules/home/lazuhyprDotfiles/.config/lf;
      ".config/ctpv".source = ../../modules/home/lazuhyprDotfiles/.config/ctpv;
      ".config/mpv".source = ../../modules/home/lazuhyprDotfiles/.config/mpv;
      ".config/fastfetch".source = ../../modules/home/lazuhyprDotfiles/.config/fastfetch;
      ".config/lsd".source = ../../modules/home/lazuhyprDotfiles/.config/lsd;
      ".config/spicetify".source = ../../modules/home/lazuhyprDotfiles/.config/spicetify;
      ".config/nvim".source = ../../modules/home/lazuhyprDotfiles/.config/nvim;
      ".config/ohmyposh".source = ../../modules/home/lazuhyprDotfiles/.config/ohmyposh;
      ".config/fish".source = ../../modules/home/lazuhyprDotfiles/.config/fish;
      ".config/bashrc".source = ../../modules/home/lazuhyprDotfiles/.config/bashrc;
    };
  };
} 