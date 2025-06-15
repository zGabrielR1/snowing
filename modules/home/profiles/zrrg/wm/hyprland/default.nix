# modules/home/profiles/zrrg/wm/hyprland/default.nix
{ pkgs, lib, config, inputs, ... }:

{
  # Enable Hyprland through Home Manager
  wayland.windowManager.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland; # Use Hyprland from flake input
    xwayland.enable = true;
    # systemd.enable = true; # If you want Hyprland to be a systemd user service

    # Plugins from hyprland-plugins flake
    # plugins = [
    #   inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
    # ];

    # Or plugins from nixpkgs
    # extraPlugins = [ pkgs.hyprland-plugins.hyprtrails ];


    settings = {
      monitor = ",preferred,auto,1";
      # Exec-once
      exec-once = [
        "waybar" # If you use Waybar
        "swaybg -i ~/Pictures/Wallpapers/your-wallpaper.png" # Example wallpaper
        "nm-applet --indicator" # Network manager applet
        # "blueman-applet" # Bluetooth applet
        "dunst" # Notification daemon
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" # Polkit agent
      ];

      # Input
      input = {
        kb_layout = "br";
        kb_variant = "nodeadkeys";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "no";
        };
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };

      # General
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(cdd6f4ff) rgba(f5c2e7cc) 45deg"; # Example Catppuccin colors
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      # Animations
      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Keybindings (examples)
      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, Q, exec, ${pkgs.kitty}/bin/kitty"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, ${pkgs.nautilus}/bin/nautilus" # Example file manager
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, ${pkgs.wofi}/bin/wofi --show drun" # Example launcher
        "$mainMod, P, pseudo," # dwindle
        "$mainMod, J, togglesplit," # dwindle

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        # ... up to 9
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        # ... up to 9
        "$mainMod SHIFT, 0, movetoworkspace, 10"
      ];
    };

    # Portal settings (if not handled system-wide by programs.hyprland.enable)
    # portal = {
    #   enable = true;
    #   extraPortals = with pkgs; [
    #     xdg-desktop-portal-gtk
    #   ];
    # };
  };

  # Hyprland related packages (moved most to home.nix, keeping only essential ones here)
  home.packages = with pkgs; [
    hyprpaper # or swaybg
    nautilus # file manager for keybinding
  ];

  # Configure Hypridle (from its flake input)
  # services.hypridle = {
  #   enable = true;
  #   package = inputs.hypridle.packages.${pkgs.system}.default;
  #   # settings = { ... };
  # };

  # Example xdg-desktop-portal config for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ];
    # Ensure this is preferred for Hyprland sessions
    config.common.default = [ "hyprland" "gtk" ];
  };
}
