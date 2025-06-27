{
  pkgs,
  lib,
  config,
  ...
}: let
  generic = [
    pkgs.foot
    pkgs.cbonsai
    pkgs.cowsay
    pkgs.mpv
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