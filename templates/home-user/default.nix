# modules/home/profiles/<username>/default.nix
# Entry point for the '<username>' user profile
{ config, lib, pkgs, inputs, ... }:

let
  # Helper function to check if a file is a Nix module
  isNixFile = name: type: 
    type == "regular" && 
    builtins.match ".*\\.nix$" name != null && 
    name != "default.nix";
  
  # Get all files in the current directory
  dirContents = builtins.readDir ./.;
  
  # Filter for Nix files only
  nixFiles = lib.filterAttrs isNixFile dirContents;
  
  # Convert to import paths
  moduleImports = lib.mapAttrsToList (name: _: ./. + "/${name}") nixFiles;

in
{
  # Auto-import all Nix modules in this directory
  imports = moduleImports;
  
  # User information
  home = {
    username = "USERNAME"; # Replace with actual username
    homeDirectory = "/home/USERNAME"; # Replace with actual username
    stateVersion = "25.11";
  };
  
  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;
  
  # XDG directories configuration
  xdg = {
    enable = true;
    
    # User directories
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      templates = "$HOME/Templates";
      publicShare = "$HOME/Public";
    };
    
    # MIME type associations
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/jpeg" = "org.gnome.eog.desktop";
        "image/png" = "org.gnome.eog.desktop";
        "video/mp4" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
      };
    };
  };
  
  # Session variables
  home.sessionVariables = {
    # Default applications
    BROWSER = "firefox";
    TERMINAL = "gnome-terminal";
    EDITOR = "vim";
    
    # Development
    MANPAGER = "less";
    
    # XDG compliance
    LESSHISTFILE = "$XDG_CACHE_HOME/less/history";
    WGETRC = "$XDG_CONFIG_HOME/wgetrc";
  };
  
  # Basic packages
  home.packages = with pkgs; [
    # Essential tools
    firefox
    git
    vim
    htop
    
    # Add user-specific packages here
  ];
  
  # Ensure required directories exist
  home.file = {
    ".cache/.keep".text = "";
    ".local/share/.keep".text = "";
    ".local/state/.keep".text = "";
  };
}