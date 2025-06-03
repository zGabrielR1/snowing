{
  inputs,
  ...
}: {
  imports = [
  #  ./wm/awesome
  # ./wm/hyprland
  #  ./wm/niri
    inputs.nix-index-db.hmModules.nix-index
    self.nixosModules.theme
  ];
  home = {
    username = "zrrg";
    homeDirectory = "/home/zrrg";
    stateVersion = "24.11";
  };


  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     lib = prev.lib // {colors = import "${self}/lib/colors" lib;};
  #   })
  # ];
}
