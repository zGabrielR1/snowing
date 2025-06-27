# modules/home/profiles/zrrg/home.nix
#
# This is the primary Home Manager configuration for the user 'zrrg'.
# It defines packages, aliases, and program settings.
# Note: Dotfiles are now managed by Hjem in users/zrrg.nix
#
{ config, pkgs, system, inputs, ... }:

let
  # --- Package Sets for Better Organization ---
  
  shell-tools = with pkgs; [
    # Shells & Prompts
    zsh
    zsh-syntax-highlighting
    zsh-autosuggestions
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
    #(inputs.windsurf.packages."${system}".windsurf)

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
  home.stateVersion = "25.11";

  # --- Shell Aliases ---
  home.shellAliases = {
    ll = "ls -l";
    update = "nh os switch --flake ~/Snow/snowing";
    # Modern replacements
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
      pull.rebase = true;
      push.autoSetupRemote = true;
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
    history = {
      size = 10000;
      save = 10000;
      share = true;
    };
    # Source our beautiful, modular rc from the dotfiles
    initContent = "source ${config.xdg.configHome}/zshrc/20-customization";
  };
  
  programs.tmux = {
    enable = true;
    # Let the dotfile handle the full configuration
    extraConfig = "source-file ${config.home.homeDirectory}/.tmux.conf";
  };

  # Also import other modules for this user
  imports = [
    ./wm/hyprland/default.nix
    inputs.zen-browser.homeModules.beta
    inputs.nix-index-db.hmModules.nix-index
  ];
}