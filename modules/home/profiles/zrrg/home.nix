# modules/home/profiles/zrrg/home.nix
# Base settings for user zrrg
{ config, pkgs, system, inputs, ... }:
{
  home.username = "zrrg";
  home.homeDirectory = "/home/zrrg";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${system}".default 
    # Windsurf IDE (latest version)
    inputs.windsurf.packages."${system}".windsurf
    # file browser
    pcmanfm

    # Editors
    helix
    kakoune
    micro
    your-editor
    vis
    emacs
    amp
    ad
    lapce
    lite-xl
    kdePackages.kate
    zed-editor

    # Utils
    optipng
    jpegoptim
    pfetch
    btop
    fastfetch
    zip
    xz
    unzip
    p7zip
    oh-my-zsh
    oh-my-posh

    #hyprstellar
    ctpv
    lf
    kitty
    mpv
    neovim
    rofi-wayland
    swaynotificationcenter
    wlogout
    wezterm
    tmux
    hypridle
    hyprlock
    hyprshade
    # Example: custom flake input package
    # inputs.zen-browser.packages."${system}".specific
    #hyprpaper
    swww
    udiskie
    glab #gitlab
    hyprsunset
    zoxide
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
    gnome-tweaks
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
  ];


  programs.zen-browser = {
    enable = true;
  };

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


  # Git configuration
  programs.git = {
    enable = true;
    userName = "zGabrielR1";
    userEmail = "gabrielrenostro581@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # Home Manager manages itself
  programs.home-manager.enable = true;

  # Home Manager state version
  home.stateVersion = "25.11";
}
