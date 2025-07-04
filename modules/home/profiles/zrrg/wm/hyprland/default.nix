# modules/home/profiles/zrrg/wm/hyprland/default.nix
{ pkgs, lib, config, inputs, ... }:

{
  # Enable Hyprland through Home Manager - DISABLED: Managed by Hjem to avoid file conflicts
  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  #
  #   # Minimal configuration to satisfy the warning
  #   # The actual configuration is handled through xdg.configFile copying
  #   extraConfig = ''
  #     # Configuration is managed through dotfiles
  #     # See ~/.config/hypr/hyprland.conf for the main configuration
  #     
  #     # Basic environment setup
  #     env = XDG_CURRENT_DESKTOP,Hyprland
  #     env = XDG_SESSION_TYPE,wayland
  #     env = XDG_SESSION_DESKTOP,Hyprland
  #   '';
  #
  #   # Plugins from hyprland-plugins flake
  #   # plugins = [
  #   #   inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
  #   # ];
  #
  #   # Or plugins from nixpkgs
  #   # extraPlugins = [ pkgs.hyprland-plugins.hyprtrails ];
  # };

  # Hyprland related packages (moved most to home.nix, keeping only essential ones here)
  home.packages = with pkgs; [
    hyprpaper # or swaybg
    nautilus # file manager for keybinding
  ];

  # Example xdg-desktop-portal config for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ];
    # Ensure this is preferred for Hyprland sessions
    config.common.default = [ "hyprland" "gtk" ];
  };
}
