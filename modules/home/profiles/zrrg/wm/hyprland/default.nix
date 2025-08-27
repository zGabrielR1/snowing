# modules/home/profiles/zrrg/wm/hyprland/default.nix
{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.wayland.windowManager.hyprland;
in
{
  # ============================================================================
  # HYPRLAND QUALITY OF LIFE CONFIGURATION
  # ============================================================================

  # Enable Hyprland with minimal configuration
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    # Use latest Hyprland from flake if available
    package = lib.mkIf (inputs ? hyprland) inputs.hyprland.packages.${pkgs.system}.hyprland;

    # Basic environment setup - can be extended by user config
    extraConfig = ''
      # Basic environment variables for Wayland compatibility
      env = XDG_CURRENT_DESKTOP,Hyprland
      env = XDG_SESSION_TYPE,wayland
      env = XDG_SESSION_DESKTOP,Hyprland

      # Load user configuration if it exists
      source = ~/.config/hypr/hyprland.conf
    '';

    # Plugins can be enabled by uncommenting
    # plugins = lib.mkIf (inputs ? hyprland-plugins) [
    #   inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
    # ];
  };

  # ============================================================================
  # HYPRLAND ECOSYSTEM PACKAGES
  # ============================================================================

  home.packages = with pkgs; [
    # Core Hyprland utilities
    hyprpaper                    # Wallpaper daemon
    hyprshot                     # Screenshot utility with region selection
    hyprpicker                   # Color picker
    hypridle                     # Idle management daemon
    hyprlock                     # Screen locker

    # Status bar and launcher
    waybar                       # Highly customizable status bar
    (rofi-wayland.override {     # Application launcher
      plugins = [ rofi-calc ];
    })

    # Notification system
    dunst                        # Lightweight notification daemon
    swaynotificationcenter       # Notification center with history

    # Essential Wayland utilities
    wl-clipboard                 # Clipboard manager for Wayland
    slurp                        # Select region for screenshots
    grim                         # Screenshot tool
    swappy                       # Screenshot editor/annotation tool
    brightnessctl                # Brightness control utility
    playerctl                    # Media player control

    # System integration
    networkmanagerapplet         # Network manager tray icon
    blueman                      # Bluetooth manager
    pavucontrol                  # PulseAudio volume control GUI

    # Qt Wayland support for Qt applications
    qt6.qtwayland                # Qt6 Wayland platform plugin
    libsForQt5.qt5.qtwayland     # Qt5 Wayland platform plugin

    # GTK integration
    gtk3                         # GTK3 for theming
    gtk4                         # GTK4 for modern GTK apps

    # File managers with Wayland support
    nautilus                     # GNOME file manager

    # Terminal with Wayland support
    kitty                        # GPU-accelerated terminal
    foot                         # Fast terminal emulator
    wezterm                      # Powerful terminal emulator

    # Additional utilities
    wlogout                      # Logout menu
    wlr-randr                    # Monitor management
    wdisplays                    # Graphical display management
    nwg-look                     # GTK theme switcher
    lxappearance-gtk2            # GTK2 theme switcher
  ];

  # ============================================================================
  # DESKTOP PORTAL CONFIGURATION
  # ============================================================================

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland  # Hyprland-specific portal
      xdg-desktop-portal-gtk       # GTK portal for file dialogs
      # xdg-desktop-portal-wlr     # Generic Wayland portal (if needed)
    ];

    config = {
      common = {
        default = [ "hyprland" "gtk" ];
        # Screen sharing and remote desktop
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        # File chooser
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        # Secret service for passwords
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };

      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
    };
  };

  # ============================================================================
  # ENVIRONMENT VARIABLES FOR WAYLAND COMPATIBILITY
  # ============================================================================

  home.sessionVariables = {
    # Hyprland session identification
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # Qt applications - enable Wayland support
    QT_QPA_PLATFORM = "wayland;xcb";  # Fallback to XCB if Wayland fails
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORMTHEME = "gtk3";  # Use GTK theme for Qt apps

    # Firefox and Mozilla applications
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";

    # SDL applications (games, media players)
    SDL_VIDEODRIVER = "wayland,x11";

    # Java applications
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # GTK applications
    GTK_USE_PORTAL = "1";  # Use portals for file dialogs

    # Cursor configuration
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";

    # Input method
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";

    # Disable accessibility (can cause issues)
    NO_AT_BRIDGE = "1";

    # Force Wayland for Electron apps
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # ============================================================================
  # SYSTEM INTEGRATION SERVICES
  # ============================================================================

  # GNOME Keyring for password management
  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" "ssh" ];
  };

  # PolicyKit authentication agent
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "PolicyKit Authentication Agent";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ============================================================================
  # MIME TYPES AND ASSOCIATIONS
  # ============================================================================

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Set default applications for common file types
      "text/plain" = [ "nvim.desktop" "code.desktop" ];
      "text/x-shellscript" = [ "kitty.desktop" ];
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "image/png" = [ "org.gnome.eog.desktop" ];
      "image/jpeg" = [ "org.gnome.eog.desktop" ];
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
    };
  };

  # ============================================================================
  # GTK THEMING CONFIGURATION
  # ============================================================================

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Sans";
      size = 10;
    };
  };

  # ============================================================================
  # QT THEMING CONFIGURATION
  # ============================================================================

  qt = {
    enable = true;
    platformTheme = "gtk3";
    style = {
      name = "gtk3";
      package = pkgs.kdePackages.qt6gtk2;
    };
  };

  # ============================================================================
  # FONT CONFIGURATION
  # ============================================================================

  fonts.fontconfig.enable = true;

  # ============================================================================
  # ADDITIONAL USER SERVICES
  # ============================================================================

  # Enable dunst notification daemon
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "10x50";
        scale = 0;
        notification_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        frame_width = 3;
        frame_color = "#aaaaaa";
        separator_color = "frame";
        sort = "yes";
        idle_threshold = 120;
        font = "Monospace 8";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";
        icon_position = "left";
        icon_theme = "Adwaita";
        sticky_history = "yes";
        history_length = 20;
        always_run_script = true;
        corner_radius = 0;
        force_xwayland = false;
        force_xinerama = false;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
    };
  };

  # ============================================================================
  # DEVELOPMENT ENVIRONMENT INTEGRATION
  # ============================================================================

  # Enable direnv for automatic environment management
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable bash integration for direnv
  programs.bash.enable = true;

  # Enable zsh integration for direnv
  programs.zsh.enable = true;
}
