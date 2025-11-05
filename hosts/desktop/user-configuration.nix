{
  pkgs,
  lib,
  config,
  ...
}: let
  # Generic packages that are useful on any host
  generic = [
    # === Terminal and Shell Tools ===
    pkgs.zsh
    
    # === System Utilities ===
    pkgs.btop
    pkgs.htop
    pkgs.eza
    pkgs.bat
    pkgs.ripgrep
    pkgs.fd
    pkgs.fzf
    pkgs.zoxide
    
    # === Development Tools ===
    pkgs.git
    pkgs.delta
    pkgs.lazygit
    
    # === Entertainment ===
    pkgs.cbonsai
    pkgs.cowsay
    pkgs.mpv
    
    # === Network Tools ===
    pkgs.curl
    pkgs.wget
    
    # === File Management ===
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