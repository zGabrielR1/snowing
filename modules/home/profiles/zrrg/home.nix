# modules/home/profiles/zrrg/home.nix
# Base settings for user zrrg
{ pkgs, lib, config, ... }:
{
  # Basic shell aliases, environment variables, etc.
  home.shellAliases = {
    ll = "ls -l";
    update = "nh os switch --flake ~/Dev/nixland"; # Example, adjust path
  };

  # GTK Theming (if not handled by a dedicated theming module)
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 11;
    };
    # theme.name = "Adwaita-dark";
    # iconTheme.name = "Papirus-Dark";
    # cursorTheme.name = "McMojave-cursors"; # If you use mcmojave-hyprcursor
  };

  # Qt Theming
  # programs.qt = {
  #   enable = true;
  #   platformTheme = "gtk"; # or "gnome" or "qtct"
  #   style = "adwaita-dark"; # or another Qt style
  # };

  # For nix-colors or similar theming solutions, integrate them here
  # Example with nix-colors (you'd need to set up nix-colors.colorScheme)
  # colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;
  # imports = [ inputs.nix-colors.homeManagerModules.default ];
}
