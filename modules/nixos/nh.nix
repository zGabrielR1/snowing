_: {
  # nh default flake
  environment.variables.FLAKE = "/home/zrrg/Dev/nixland";

  programs.nh = {
    enable = true;
    # weekly cleanup
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d";
    };
  };
}
