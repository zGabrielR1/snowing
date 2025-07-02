{
  pkgs,
  lib,
  config,
  ...
}: let
  # Generic packages that are useful on any host
  generic = [
    # Terminal and shell tools
    pkgs.foot
    pkgs.zsh
    pkgs.fish
    
    # System utilities
    pkgs.btop
    pkgs.htop
    pkgs.eza
    pkgs.bat
    pkgs.ripgrep
    pkgs.fd
    pkgs.fzf
    pkgs.zoxide
    
    # Development tools
    pkgs.git
    pkgs.delta
    pkgs.lazygit
    
    # Entertainment
    pkgs.cbonsai
    pkgs.cowsay
    pkgs.mpv
    
    # Network tools
    pkgs.curl
    pkgs.wget
    pkgs.nmap
    
    # File management
    pkgs.unzip
    pkgs.p7zip
    pkgs.rsync
  ];
  special = builtins.attrValues {
    # Add any host-specific packages here
  };
in {
  users.users."zrrg" = {
    packages = special ++ generic;
    extraGroups = ["video" "input"];
  };

  # Add any host-specific user configurations here
  # For example, if you want to add specific dotfiles for this host:
  # hjem.users."zrrg".files = {
  #   ".config/host-specific".source = ./host-specific-config;
  # };
} 