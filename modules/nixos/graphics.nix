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
    hardware.graphics = {
      enable = true;
      
      extraPackages = with pkgs; (
        (if cfg.intel.enable then [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ] else [])
        ++
        (if cfg.amd.enable then [
          rocm-opencl-icd
          rocm-opencl-runtime
        ] else [])
      );
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
