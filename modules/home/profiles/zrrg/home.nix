# modules/home/profiles/zrrg/home.nix
#
# This is the primary Home Manager configuration for the user 'zrrg'.
# It defines packages, aliases, and program settings.
# Note: Dotfiles are now managed by Hjem in users/zrrg.nix
#
{ config, pkgs, inputs, ... }:

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
    #wezterm

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
    nodejs_24

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
    #jetbrains-toolbox

    # Programming Language Support
    tokei # code stats
  ];

  gui-apps = with pkgs; [
    # Browser
    (inputs.zen-browser.packages.${pkgs.system}.default)
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
    hyprshot
    # Bar & Launchers
    waybar
    rofi-wayland
    walker
    #wofi

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
    #pywal16
    spicetify-cli
  ];
  /*
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
  */

in
{
  home.username = "zrrg";
  home.homeDirectory = "/home/zrrg";

  # --- Combine all package lists ---
  home.packages = 
    shell-tools ++ 
    dev-tools ++
    gui-apps ++
    hyprland-ecosystem;

  # --- State Version ---
  home.stateVersion = "25.11";

  # --- Shell Aliases ---
  home.shellAliases = {
    # Basic aliases
    ll = "ls -l";
    la = "ls -la";
    l = "ls -CF";
    
    # System management
    update = "nh os switch --flake ~/Documentos/snowing";
    rebuild = "sudo nixos-rebuild switch --flake ~/Documentos/snowing";
    
    # Modern replacements
    ls = "eza --icons --group-directories-first";
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
    
    # Development shortcuts
    g = "git";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
    gs = "git status";
    gd = "git diff";
    gco = "git checkout";
    gcb = "git checkout -b";
    
    # Directory navigation
    # .. = "cd ..";
    # ... = "cd ../..";
    # .... = "cd ../../..";
    
    # Quick access
    config = "cd ~/Documentos/snowing";
    docs = "cd ~/Documents";
    dl = "cd ~/Downloads";
    dt = "cd ~/Desktop";
  };

  # --- Program Configurations ---
  programs.home-manager.enable = true;

  # Browser configuration
  #programs.zen-browser = {
  #  enable = true;
  #};

  # Zsh configuration - DISABLED: Managed by Hjem to avoid file conflicts
  # programs.zsh = {
  #   enable = true;
  #   enableCompletion = true;
  #   autosuggestion.enable = true;
  #   syntaxHighlighting.enable = true;
  #   history = {
  #     size = 10000;
  #     save = 10000;
  #     share = true;
  #     ignoreDups = true;
  #     ignoreSpace = true;
  #   };
  #   # Source our beautiful, modular rc from the dotfiles
  #   initContent = "source ${config.xdg.configHome}/zshrc/20-customization";
  # };
  
  # Tmux configuration - DISABLED: Managed by Hjem to avoid file conflicts
  # programs.tmux = {
  #   enable = true;
  #   # Let the dotfile handle the full configuration
  #   extraConfig = "source-file ${config.home.homeDirectory}/.tmux.conf";
  # };

  # Git delta configuration - DISABLED: Managed by Hjem to avoid file conflicts
  programs.git = {
    enable = true;
    userName = "zGabrielR1";
    userEmail = "gabrielrenostro581@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = true;
      push.autoSetupRemote = true;
      credential.helper = "store";
      color.ui = "auto";
      color.branch = "auto";
      color.status = "auto";
    };
    # delta = {
    #   enable = true;
    #   options = {
    #     navigate = true;
    #     light = false;
    #     side-by-side = true;
    #     line-numbers = true;
    #   };
    # };
  };

  # In home.nix
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "zen-browser";
    TERMINAL = "kitty";
    XDG_CONFIG_HOME = "$HOME/.config";
  };

  # Also import other modules for this user
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

}
