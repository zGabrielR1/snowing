{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.snowing.graphics;
in {
  options.snowing.graphics = {
    enable = mkEnableOption "graphics support";
    intel.enable = mkEnableOption "intel graphics";
    nvidia.enable = mkEnableOption "nvidia graphics";
    amd.enable = mkEnableOption "amd graphics";
  };

  config = mkIf cfg.enable {
    # Intel graphics
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      extraPackages =
        (mkIf cfg.intel.enable (with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ]))
        ++
        (mkIf cfg.amd.enable (with pkgs; [
          rocm-opencl-icd
          rocm-opencl-runtime
        ]));
    };

    # Nvidia specific configuration
    hardware.nvidia = mkIf cfg.nvidia.enable {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Common graphics packages
    environment.systemPackages = with pkgs; [
      glxinfo
      vulkan-tools
      vulkan-loader
      vulkan-validation-layers
    ];
  };
}
