# modules/home/profiles/zrrg/home.nix
# Base settings for user zrrg
{ config, pkgs, system, inputs, ... }:
{
  home.username = "zrrg";
  home.homeDirectory = "/home/zrrg";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Browser
    inputs.zen-browser.packages."${system}".default 
    # Windsurf IDE (latest version)
    inputs.windsurf.packages."${system}".windsurf
    
    # File browsers and managers
    pcmanfm
    lf
    ctpv

    # Terminal and shells
    kitty
    wezterm
    tmux
    fish
    zsh
    oh-my-zsh
    oh-my-posh

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
    neovim
    # Development tools
    lazygit
    glab # gitlab
    delta # git diff viewer
    fzf
    sesh # tmux session manager

    # System utilities
    optipng
    jpegoptim
    pfetch
    btop
    fastfetch
    zip
    xz
    unzip
    p7zip
    brightnessctl
    pavucontrol
    networkmanagerapplet
    polkit_gnome
    gnome-tweaks

    #hyprstellar
    ctpv
    lf
    kitty
    mpv
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
    swww
    waybar
    swaynotificationcenter
    wlogout
    rofi-wayland
    wofi
    wl-clipboard
    slurp
    grim
    swappy
    
    pywal16

    # Other utilities
    udiskie
    zoxide
    dunst
    mpv
    spicetify-cli

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji

    # Tmux plugins (for tpm)
    tmuxPlugins.sensible
    tmuxPlugins.vim-tmux-navigator

    # Shell enhancements
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
    starship

    # Additional tools that might be needed
    ripgrep
    fd
    bat
    eza
    lsd
    tree
    htop
    bottom
    du-dust
    procs
    sd
    tokei
    hyperfine
    bandwhich
    gping
    dog
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

  programs.zen-browser = {
    enable = true;
  };

  # Shell aliases
  home.shellAliases = {
    ll = "ls -l";
    update = "nh os switch --flake ~/Dev/nixland";
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
  /*
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
  */
  # Git configuration
  programs.git = {
    enable = true;
    userName = "zGabrielR1";
    userEmail = "gabrielrenostro581@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
    };
  };

  # Home Manager manages itself
  programs.home-manager.enable = true;

  # Home Manager state version
  home.stateVersion = "25.11";
}
