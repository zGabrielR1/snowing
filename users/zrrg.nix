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
  # Add user to snowing data.users list
  snowing.data.users = [username];

  users.users.${username} = {
    inherit description;
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "incus-admin"
      "podman"
      "docker"
      "multimedia"
      "video"
      "audio"
      "input"
      "kvm"
      "libvirtd"
      "lp"
      "scanner"
    ];

    # Common packages for all hosts - moved to user-configuration.nix to avoid duplication
    packages = [ ];
  };


  # ============================================================================
  # ADDITIONAL USER-SPECIFIC CONFIGURATIONS
  # ============================================================================

  # Enable Home Manager for this user (if not already enabled in main config)
  # home-manager.users.${username} = {
  #   imports = [
  #     ../modules/home/profiles/zrrg/default.nix
  #   ];
  # };

  # User-specific systemd services
  systemd.user.services = {
    # Example: Auto-start a service for this user
    # my-service = {
    #   Unit.Description = "My user service";
    #   Service.ExecStart = "${pkgs.my-package}/bin/my-command";
    #   Install.WantedBy = [ "default.target" ];
    # };
  };

  # User-specific environment variables
  environment.sessionVariables = {
    # Add any user-specific environment variables here
    # EDITOR = "nvim";
    # BROWSER = "firefox";
  };
}
