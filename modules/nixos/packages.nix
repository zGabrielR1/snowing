{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Custom VSCode Insiders build
    /*((pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: rec {
      src = (builtins.fetchTarball {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
        sha256 = "sha256:1ys4d79pnf1y4aslq0bnm20cgmmfcgl7cd3lhw88h41mx2bi1hfl";
      });
      version = "latest";
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
    }))
    */
    nano
    code-cursor
    #windsurf
    git
    gh
    runc
    #cri-o
    distrobox
    distroshelf
    apx
    apx-gui
    #boxbuddy
    toolbox
    podman
    pods
    github-desktop
    kitty
    awesome
    niri
    flatpak
    rofi-wayland
    bottles
    wineWowPackages.stagingFull
    jetbrains-toolbox
    
  ];
}
