{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.vm;
  
  vmType = types.enum [ "virt-manager" "virtualbox" "both" ];
  vfioType = types.enum [ "intel" "amd" "none" ];
  
  # Common VFIO kernel modules
  vfioModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    "vfio_virqfd"
  ];
  
  # Common graphics drivers that might conflict with VFIO
  graphicsDrivers = [
    "i915"      # Intel
    "amdgpu"    # AMD
    "radeon"    # AMD legacy
    "nvidia"    # NVIDIA
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    "nouveau"   # NVIDIA open source
  ];
in

{
  options.virtualisation.vm = {
    enable = mkEnableOption "virtual machine virtualization";
    
    type = mkOption {
      type = vmType;
      default = "virt-manager";
      description = "Type of virtualization to enable: virt-manager (libvirt), virtualbox, or both";
    };
    
    username = mkOption {
      type = types.str;
      description = "Username to add to virtualization groups";
    };
    
    # VFIO/GPU Passthrough Options
    vfio = {
      enable = mkEnableOption "VFIO/GPU passthrough support";
      
      platform = mkOption {
        type = vfioType;
        default = "none";
        description = "CPU platform for IOMMU: intel, amd, or none";
      };
      
      gpuIds = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of GPU PCI IDs to passthrough (format: vendor:device)";
        example = [ "10de:2482" "10de:228b" "1002:67b0" "1002:aac8" ];
      };
      
      blacklistGraphics = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to blacklist graphics drivers to prevent conflicts";
      };
      
      blacklistedDrivers = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional graphics drivers to blacklist";
        example = [ "amdgpu" "radeon" "nvidia" ];
      };
      
      loadGraphicsAfterVfio = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to load graphics drivers after VFIO modules";
      };
      
      graphicsDrivers = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Graphics drivers to load after VFIO modules";
        example = [ "i915" "nvidia" "nvidia_modeset" ];
      };
      
      # Single GPU Passthrough Options
      singleGpuPassthrough = mkOption {
        type = types.bool;
        default = false;
        description = "Enable single GPU passthrough (host becomes headless when VM is running)";
      };
      
      hostGraphicsDriver = mkOption {
        type = types.str;
        default = "i915";
        description = "Graphics driver to use for host when VM is not running";
        example = "i915";
      };
      
      enableVgaSwitcheroo = mkOption {
        type = types.bool;
        default = false;
        description = "Enable VGA switcheroo for dynamic GPU switching";
      };
    };
    
    # Advanced libvirt options
    libvirt = {
      enableOvmf = mkOption {
        type = types.bool;
        default = true;
        description = "Enable OVMF (UEFI firmware) support";
      };
      
      enableSecureBoot = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Secure Boot in OVMF";
      };
      
      enableTpm = mkOption {
        type = types.bool;
        default = true;
        description = "Enable TPM emulation";
      };
      
      enableSpice = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SPICE USB redirection";
      };
    };
  };

  config = mkIf cfg.enable {
    # Basic virtualization setup
    programs.virt-manager.enable = mkIf (cfg.type == "virt-manager" || cfg.type == "both") true;
    
    users.groups.libvirtd.members = mkIf (cfg.type == "virt-manager" || cfg.type == "both") (lib.mkBefore [ cfg.username ]);
    
    virtualisation.spiceUSBRedirection.enable = mkIf (cfg.type == "virt-manager" || cfg.type == "both") cfg.libvirt.enableSpice;
    
    # VirtualBox configuration
    virtualisation.virtualbox.host.enable = mkIf (cfg.type == "virtualbox" || cfg.type == "both") true;
    
    users.extraGroups.vboxusers.members = mkIf (cfg.type == "virtualbox" || cfg.type == "both") (lib.mkBefore [ cfg.username ]);
    
    virtualisation.virtualbox.host.enableExtensionPack = mkIf (cfg.type == "virtualbox" || cfg.type == "both") true;
    
    # VFIO/GPU Passthrough Configuration
    boot = mkIf cfg.vfio.enable {
      initrd.kernelModules = vfioModules ++ 
        (lib.optionals cfg.vfio.loadGraphicsAfterVfio cfg.vfio.graphicsDrivers);
      
      kernelParams = 
        # IOMMU platform selection
        (lib.optionals (cfg.vfio.platform == "intel") [ "intel_iommu=on" ]) ++
        (lib.optionals (cfg.vfio.platform == "amd") [ "amd_iommu=on" ]) ++
        # GPU passthrough IDs
        (lib.optionals (cfg.vfio.gpuIds != []) 
          [ ("vfio-pci.ids=" + lib.concatStringsSep "," cfg.vfio.gpuIds) ]) ++
        # Graphics driver parameters to prevent conflicts
        (lib.optionals cfg.vfio.blacklistGraphics [
          "radeon.runpm=0"
          "radeon.modeset=0"
          "amdgpu.runpm=0"
          "amdgpu.modeset=0"
          "nouveau.runpm=0"
          "nouveau.modeset=0"
        ]) ++
        # Single GPU passthrough specific configurations
        (lib.optionals cfg.vfio.singleGpuPassthrough [
          "video=efifb:off"
          "video=vesafb:off"
          "video=simplefb:off"
          "vga=off"
        ]) ++
        # VGA switcheroo configuration for single GPU passthrough
        (lib.optionals (cfg.vfio.singleGpuPassthrough && cfg.vfio.enableVgaSwitcheroo) [
          "vga_switcheroo=1"
        ]);
      
      blacklistedKernelModules = lib.optionals cfg.vfio.blacklistGraphics 
        (cfg.vfio.blacklistedDrivers ++ [ "amdgpu" "radeon" "nouveau" ]);
    };
    
    # Enhanced libvirt configuration with OVMF
    virtualisation.libvirtd = mkIf (cfg.type == "virt-manager" || cfg.type == "both") {
      enable = true;
      qemu = mkIf cfg.libvirt.enableOvmf {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = cfg.libvirt.enableTpm;
        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
            secureBoot = cfg.libvirt.enableSecureBoot;
            tpmSupport = cfg.libvirt.enableTpm;
          }).fd];
        };
      };
    };
    
    # Hardware support
    hardware.opengl.enable = mkIf cfg.vfio.enable true;
    
    # Additional packages for VFIO/GPU passthrough
    environment.systemPackages = mkIf (cfg.vfio.enable && (cfg.type == "virt-manager" || cfg.type == "both")) [
      pkgs.OVMF
      pkgs.qemu
      pkgs.dnsmasq
      pkgs.edk2
      # Convenience script for QEMU with UEFI
      (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
        qemu-system-x86_64 \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        "$@"
      '')
    ] ++ lib.optionals cfg.vfio.singleGpuPassthrough [
      # Single GPU passthrough utilities
      pkgs.vga-switcheroo
      # Script to handle single GPU passthrough
      (pkgs.writeShellScriptBin "single-gpu-passthrough" ''
        #!/bin/bash
        # Single GPU passthrough helper script
        
        case "$1" in
          "start")
            echo "Preparing for single GPU passthrough..."
            # Unbind GPU from host
            echo 0000:01:00.0 > /sys/bus/pci/devices/0000:01:00.0/driver/unbind 2>/dev/null || true
            echo 0000:01:00.1 > /sys/bus/pci/devices/0000:01:00.1/driver/unbind 2>/dev/null || true
            # Bind to vfio-pci
            echo 0000:01:00.0 > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true
            echo 0000:01:00.1 > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true
            echo "GPU bound to vfio-pci"
            ;;
          "stop")
            echo "Restoring GPU to host..."
            # Unbind from vfio-pci
            echo 0000:01:00.0 > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
            echo 0000:01:00.1 > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
            # Rebind to host driver
            echo 0000:01:00.0 > /sys/bus/pci/drivers/${cfg.vfio.hostGraphicsDriver}/bind 2>/dev/null || true
            echo 0000:01:00.1 > /sys/bus/pci/drivers/${cfg.vfio.hostGraphicsDriver}/bind 2>/dev/null || true
            echo "GPU restored to host"
            ;;
          *)
            echo "Usage: single-gpu-passthrough {start|stop}"
            echo "  start: Prepare GPU for passthrough"
            echo "  stop:  Restore GPU to host"
            ;;
        esac
      '')
    ];
  };
} 