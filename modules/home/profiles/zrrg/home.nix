# modules/home/profiles/zrrg/home.nix
#
# This is the primary Home Manager configuration for the user 'zrrg'.
# It defines packages, aliases, dotfiles, and program settings.
#
{ config, pkgs, system, inputs, ... }:

let
  # --- Package Sets for Better Organization ---
  
  shell-tools = with pkgs; [
    # Shells & Prompts
    zsh
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-autocomplete
    zsh-completions
    fish
    oh-my-zsh
    oh-my-posh

    # Terminal Multiplexers
    tmux
    tmuxPlugins.sensible
    tmuxPlugins.vim-tmux-navigator
    sesh
    kitty
    wezterm

    # Core Utilities
    optipng
    jpegoptim
    zoxide
    fzf
    bat
    eza
    lsd
    tree
    ripgrep
    fd
    sd
    unzip
    p7zip
    zip
    xz

    # System Monitors
    btop
    htop
    bottom
    fastfetch
    pfetch
    du-dust
    procs
    hyperfine
    
    # Network Tools
    gping
    dog
    bandwhich

    # xh
    # curlie
    # as-tree
    # choose
    # jq
    # yq
    # htmlq
    # pup
    # csvkit
    # miller
    # q
    # rush
    # tuc
  ];

  dev-tools = with pkgs; [
    # Git & Related
    git
    lazygit
    gh
    glab
    delta

    # Editors & IDEs
    neovim
    helix
    kakoune
    micro
    emacs
    lapce
    your-editor
    amp
    ad
    vis
    lite-xl
    zed-editor
    jetbrains-toolbox
    (inputs.windsurf.packages."${system}".windsurf)

    # Programming Language Support
    tokei # code stats
  ];

  gui-apps = with pkgs; [
    # Browser
    (inputs.zen-browser.packages."${system}".default)

    # File Managers
    pcmanfm
    nautilus
    lf
    ctpv

    # Utilities
    bottles
    refine
    #gnome-tweaks
    kdePackages.kate
    vesktop
    mpv
    dunst
  ];

  hyprland-ecosystem = with pkgs; [
    # Compositor & Core
    hyprland
    hyprpaper
    hyprlock
    hypridle
    hyprshade
    hyprsunset
    
    # Bar & Launchers
    waybar
    rofi-wayland
    wofi

    # System Utilities
    swww
    swaynotificationcenter
    wlogout
    wl-clipboard
    slurp
    grim
    swappy
    brightnessctl
    pavucontrol
    networkmanagerapplet
    polkit_gnome
    udiskie

    # Theming
    pywal16
    spicetify-cli
  ];
  
  fonts = with pkgs; [
    # Nerd Fonts
    nerd-fonts.jetbrains-mono
    #(nerd-fonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Meslo" ]; })
    nerd-fonts.symbols-only
    
    # Standard Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    openmoji-color
    twemoji-color-font
  ];

in
{
  home.username = "zrrg";
  home.homeDirectory = "/home/zrrg";

  # --- Combine all package lists ---
  home.packages = 
    shell-tools ++ 
    dev-tools ++
    gui-apps ++
    hyprland-ecosystem ++
    fonts;

  # --- State Version ---
  home.stateVersion = "25.11"; # Set to your current version

  home.shellAliases = {
  ll = "ls -l";
  update = "nh os switch --flake ~/Snow/snowing";
  # Additional aliases from dotfiles
  ls = "lsd";
  cat = "bat";
  grep = "rg";
  find = "fd";
  top = "btm";
  ps = "procs";
  du = "dust";
  df = "duf";
  ping = "gping";
  dig = "dog";
  curl = "xh";
  wget = "xh";
  http = "xh";
  https = "xh";
};

  # --- Program Configurations ---
  programs.home-manager.enable = true;

  programs.zen-browser = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "zGabrielR1";
    userEmail = "gabrielrenostro581@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    # Source our beautiful, modular   rc from the dotfiles
    initExtra = "source ${config.xdg.configHome}/zshrc/20-customization";
  };
  
  programs.tmux = {
    enable = true;
    # Let the dotfile handle the full configuration
    extraConfig = "source-file ${config.home.homeDirectory}/.tmux.conf";
  };

  # --- Dotfile Management ---
  # This section links your dotfiles from the *single source* into the correct locations.
  # Note the updated path to lazuhyprDotfiles.
  xdg.configFile = {
    "zshrc".source = ../../lazuhyprDotfiles/.config/zshrc;
    "hypr".source = ../../lazuhyprDotfiles/.config/hypr;
    "waybar".source = ../../lazuhyprDotfiles/.config/waybar;
    "rofi".source = ../../lazuhyprDotfiles/.config/rofi;
    "swaync".source = ../../lazuhyprDotfiles/.config/swaync;
    "wlogout".source = ../../lazuhyprDotfiles/.config/wlogout;
    "wezterm".source = ../../lazuhyprDotfiles/.config/wezterm;
    "btop".source = ../../lazuhyprDotfiles/.config/btop;
    "lf".source = ../../lazuhyprDotfiles/.config/lf;
    "ctpv".source = ../../lazuhyprDotfiles/.config/ctpv;
    "mpv".source = ../../lazuhyprDotfiles/.config/mpv;
    "fastfetch".source = ../../lazuhyprDotfiles/.config/fastfetch;
    "lsd".source = ../../lazuhyprDotfiles/.config/lsd;
    "spicetify".source = ../../lazuhyprDotfiles/.config/spicetify;
    "nvim".source = ../../lazuhyprDotfiles/.config/nvim;
    "ohmyposh".source = ../../lazuhyprDotfiles/.config/ohmyposh;
    "fish".source = ../../lazuhyprDotfiles/.config/fish;
    "bashrc".source = ../../lazuhyprDotfiles/.config/bashrc;
  };
  
  home.file = {
    # Note the updated path to lazuhyprDotfiles.
    ".zshrc".source = ../../lazuhyprDotfiles/.zshrc;
    ".tmux.conf".source = ../../lazuhyprDotfiles/.tmux.conf;
    ".vimrc".source = ../../lazuhyprDotfiles/.vimrc;
    ".bashrc".source = ../../lazuhyprDotfiles/.bashrc;
    ".gtkrc-2.0".source = ../../lazuhyprDotfiles/.gtkrc-2.0;
    ".Xresources".source = ../../lazuhyprDotfiles/.Xresources;
    ".ideavimrc".source = ../../lazuhyprDotfiles/.ideavimrc;
    ".delta-themes.gitconfig".source = ../../lazuhyprDotfiles/.delta-themes.gitconfig;
    ".stow-local-ignore".source = ../../lazuhyprDotfiles/.stow-local-ignore;
  };

  # Also import other modules for this user
  imports = [
    ./wm/hyprland/default.nix
    inputs.zen-browser.homeModules.beta
    inputs.nix-index-db.hmModules.nix-index
  ];
}