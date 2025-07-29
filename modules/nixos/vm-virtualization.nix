{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.vm;
  
  # Type definition for virtualization type
  vmType = mkOptionType {
    name = "vmType";
    description = "Virtualization type (only QEMU/KVM with virt-manager is supported)";
    check = x: x == "virt-manager";
    merge = mergeOneOption;
  };
  
  vfioType = mkOptionType {
    name = "vfioType";
    description = "CPU platform type for VFIO";
    check = x: elem x [ "intel" "amd" "none" ];
    merge = mergeOneOption;
  };
  
  pciIdType = types.strMatching "[0-9a-fA-F]{4}:[0-9a-fA-F]{4}";
  
  # Common VFIO kernel modules with better compatibility
  vfioModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    #"vfio_virqfd"
    "kvmgt"
  ];
  
  # Common graphics drivers that might conflict with VFIO
  graphicsDrivers = [
    "i915"           # Intel
    "amdgpu"         # AMD
    "radeon"         # AMD legacy
    "nvidia"         # NVIDIA
    "nvidia_drm"     # NVIDIA DRM
    "nvidia_modeset" # NVIDIA Modesetting
    "nvidia_uvm"     # NVIDIA Unified Memory
    "nouveau"        # NVIDIA open source
  ];
  
  # Helper functions for VFIO configuration
  vfioModprobeConfig = gpuIds:
    "options vfio-pci ids=${concatStringsSep "," gpuIds} disable_vga=1";
  
  vfioKernelParams = vfioCfg: (
    # IOMMU platform selection
    (optional (vfioCfg.platform == "intel") "intel_iommu=on iommu=pt")
    ++ optional (vfioCfg.platform == "amd") "amd_iommu=on"
    # GPU passthrough IDs
    ++ optional (vfioCfg.gpuIds != []) 
       ("vfio-pci.ids=" + concatStringsSep "," vfioCfg.gpuIds)
    # Graphics driver parameters to prevent conflicts
    ++ optionals vfioCfg.blacklistGraphics [
      "rd.driver.blacklist=${concatStringsSep "," (graphicsDrivers ++ vfioCfg.blacklistedDrivers)}"
      "modprobe.blacklist=${concatStringsSep "," (graphicsDrivers ++ vfioCfg.blacklistedDrivers)}"
    ]
    # Single GPU passthrough specific configurations
    ++ optionals vfioCfg.singleGpuPassthrough [
      "video=efifb:off"
      "video=vesafb:off"
      "video=simplefb:off"
      "vga=off"
    ]
  );
in

{
  options.virtualisation.vm = mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "virtual machine virtualization";
        
        type = mkOption {
          type = vmType;
          default = "virt-manager";
          description = "Enable QEMU/KVM with libvirt (virt-manager) for virtualization";
          readOnly = true;  # Since there's only one option now
        };
        
        username = mkOption {
          type = types.str;
          description = "Username to add to virtualization groups";
          example = "alice";
        };
    
        # VFIO/GPU Passthrough Options
        vfio = {
          enable = mkEnableOption "VFIO/GPU passthrough support";
          
          platform = mkOption {
            type = vfioType;
            default = "none";
            description = "CPU platform for IOMMU: intel, amd, or none";
            example = "intel";
          };
          
          gpuIds = mkOption {
            type = types.listOf pciIdType;
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
          
          # New: HugePages configuration
          hugepages = {
            enable = mkEnableOption "HugePages for better performance";
            size = mkOption {
              type = types.str;
              default = "1G";
              description = "Size of HugePages to allocate (e.g., 2M, 1G)";
            };
            count = mkOption {
              type = types.int;
              default = 8;
              description = "Number of HugePages to allocate";
            };
          };
          
          # New: Looking Glass support
          lookingGlass = {
            enable = mkEnableOption "Looking Glass for low-latency display";
            user = mkOption {
              type = types.str;
              default = cfg.username;
              description = "User that will run the Looking Glass client";
            };
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
            description = "Enable TPM 2.0 emulation";
          };
          
          enableSpice = mkOption {
            type = types.bool;
            default = true;
            description = "Enable SPICE USB redirection";
          };
          
          # New: CPU pinning
          cpuPinning = {
            enable = mkEnableOption "CPU pinning for better performance";
            cpuset = mkOption {
              type = types.str;
              default = "0-7";
              description = "CPUs to pin the VM to (e.g., 0-7,8-15)";
            };
          };
          
          # New: IOMMU groups
          iommuGroups = {
            enable = mkEnableOption "IOMMU group validation";
            check = mkEnableOption "Verify IOMMU groups at boot";
          };
        };
        
        # New: Performance tuning
        performance = {
          enable = mkEnableOption "Performance tuning options";
          
          cpu = {
            enable = mkEnableOption "CPU performance tuning";
            governor = mkOption {
              type = types.str;
              default = "performance";
              description = "CPU frequency governor";
            };
          };
          
          network = {
            enable = mkEnableOption "Network performance tuning";
            virtioNet = mkEnableOption "Use virtio-net for better network performance";
          };
          
          storage = {
            enable = mkEnableOption "Storage performance tuning";
            ioUring = mkEnableOption "Enable io_uring for better disk I/O";
          };
        };
  };

  config = mkIf cfg.enable (mkMerge [
    # Basic virtualization setup
    {
      # Documentation
      documentation.nixos.includeAllModules = true;
      
      # Libvirt configuration
      programs.virt-manager.enable = true;
      
      # User and group configuration
      users.groups = {
        libvirtd.members = [ cfg.username ];
        kvm.members = [ cfg.username ];
      };
      
      # Add user to additional groups for VFIO/VM management
      users.users.${cfg.username} = {
        extraGroups = mkIf cfg.vfio.enable [
          "qemu-libvirtd"
          "libvirtd"
          "disk"
          "kvm"
          "input"
          "video"
        ] ++ optional cfg.vfio.lookingGlass.enable "kvm";
      };
      
      # Virtualization configuration
      virtualisation = {
        spiceUSBRedirection.enable = cfg.libvirt.enableSpice;
        
        # Container runtimes (kept as they're lightweight and useful with KVM)
        lxd.enable = false;  # Explicitly disabled, can be enabled separately if needed
        podman.enable = false;  # Explicitly disabled, can be enabled separately if needed
        docker.enable = false;  # Explicitly disabled, can be enabled separately if needed
      };
      
      # Performance tuning
      powerManagement.cpuFreqGovernor = mkIf cfg.performance.enable (mkDefault "performance");
      
      # Kernel tuning for better VM performance
      boot.kernel.sysctl = mkIf (cfg.performance.enable) {
        # Network performance
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_max" = 16777216;
        "net.ipv4.tcp_rmem" = "4096 87380 16777216";
        "net.ipv4.tcp_wmem" = "4096 16384 16777216";
        # VM performance
        "vm.swappiness" = 10;
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 5;
      };
    }
    
    # VFIO/GPU Passthrough Configuration
    (mkIf cfg.vfio.enable {
      # Required kernel modules
      boot.initrd.kernelModules = vfioModules
        ++ optionals cfg.vfio.loadGraphicsAfterVfio cfg.vfio.graphicsDrivers
        ++ optionals cfg.vfio.lookingGlass.enable [ "kvmfr" ];
      
      # Kernel parameters
      boot.kernelParams = vfioKernelParams cfg.vfio;
      
      # Blacklist conflicting drivers
      boot.blacklistedKernelModules = 
        if cfg.vfio.blacklistGraphics then
          (graphicsDrivers ++ cfg.vfio.blacklistedDrivers)
        else
          cfg.vfio.blacklistedDrivers;
      
      # Modprobe configuration
      boot.extraModprobeConfig = vfioModprobeConfig cfg.vfio.gpuIds;
      
      # HugePages configuration
      boot.kernel.sysctl = mkIf cfg.vfio.hugepages.enable ({
        "vm.nr_hugepages" = cfg.vfio.hugepages.count;
        "vm.hugetlb_shm_group" = config.users.groups.kvm.gid;
      } // (if cfg.vfio.hugepages.size == "1G" then {
        "vm.nr_hugepages_mempolicy" = cfg.vfio.hugepages.count;
      } else {}));
      
      # System packages for VFIO features
      environment.systemPackages = with pkgs; (
        # Looking Glass packages
        (optionals cfg.vfio.lookingGlass.enable [
          looking-glass-client
          spice-gtk
        ]) ++
        # IOMMU group validation script
        (optionals cfg.libvirt.iommuGroups.enable [
          (writeScriptBin "check-iommu" ''
            #!${pkgs.runtimeShell}
            shopt -s nullglob
            for g in /sys/kernel/iommu_groups/*; do
                echo "IOMMU Group ''${g##*:}:"
                for d in "$g"/devices/*; do
                    echo -e "\t"$(lspci -nns "''${d##*/}")
                done
            done
          '')
        ])
      );
      
      # udev rules for Looking Glass
      services.udev.extraRules = mkIf cfg.vfio.lookingGlass.enable ''
        # Looking Glass
        SUBSYSTEM=="kvmfr", OWNER="${cfg.vfio.lookingGlass.user}", GROUP="kvm", MODE="0660"
      '';
      
      # TPM 2.0 support
      services.tpm2.enable = mkIf cfg.libvirt.enableTpm true;
      
      # OVMF firmware
      virtualisation.libvirtd = mkIf (cfg.type == "virt-manager") {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = cfg.libvirt.enableTpm;
          ovmf = {
            enable = cfg.libvirt.enableOvmf;
            packages = [
              (pkgs.OVMF.override {
                secureBoot = cfg.libvirt.enableSecureBoot;
                tpmSupport = cfg.libvirt.enableTpm;
              })
            ];
          };
        };
      };
      
      # CPU performance governor
      powerManagement.cpuFreqGovernor = mkIf (cfg.performance.enable && cfg.performance.cpu.enable) 
        (mkForce cfg.performance.cpu.governor);
    })
    
    # Libvirt configuration for QEMU/KVM
    (mkIf (cfg.type == "virt-manager") {
      # QEMU/KVM with libvirt daemon configuration
      virtualisation.libvirtd = {
        enable = true;
        
        # Performance optimizations
        onBoot = "ignore";
        onShutdown = "shutdown";
        
        # Use KVM by default with performance optimizations
        qemu = {
          package = if cfg.libvirt.cpuPinning.enable then
            (pkgs.qemu_kvm.override {
              smbdSupport = true;
              seccompSupport = true;
            })
          else
            pkgs.qemu_kvm;
            
          runAsRoot = true;
          
          # Performance optimizations
          verbatimConfig = ''
            nvram = [
              "${pkgs.OVMF}/FV/OVMF.fd:${pkgs.OVMF}/FV/OVMF_VARS.fd"
            ]
          '';
        };
        
        # Network configuration
        allowedBridges = [ "virbr0" "virbr1" ];
      };
      
      # Firewall rules for libvirt
      networking.firewall.checkReversePath = false;
      
      # SPICE configuration
      environment.etc = {
        "polkit-1/rules.d/50-libvirt.rules" = mkIf cfg.libvirt.enableSpice {
          text = ''
            polkit.addRule(function(action, subject) {
              if (action.id == "org.libvirt.unix.manage" &&
                  subject.isInGroup("libvirt")) {
                return polkit.Result.YES;
              }
            });
          '';
        };
      };
    })
    
    # Performance tuning
    (mkIf cfg.performance.enable {
      # Network performance tuning
      boot.kernel.sysctl = mkIf cfg.performance.network.enable {
        # Increase TCP buffer sizes
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_max" = 16777216;
        "net.ipv4.tcp_rmem" = "4096 87380 16777216";
        "net.ipv4.tcp_wmem" = "4096 16384 16777216";
        # Reduce latency
        "net.ipv4.tcp_low_latency" = 1;
        "net.core.netdev_max_backlog" = 300000;
      };
      
      # Storage performance tuning
      boot.kernelParams = mkIf cfg.performance.storage.enable [
        "elevator=none"
        "scsi_mod.use_blk_mq=1"
        "scsi_mod.default_dev_flags=0"
      ] ++ optionals cfg.performance.storage.ioUring [
        "scsi_mod.default_dev_flags=0"
        "scsi_mod.use_blk_mq=1"
      ];
      
      # CPU performance tuning
      powerManagement.cpuFreqGovernor = mkIf cfg.performance.cpu.enable 
        (mkForce cfg.performance.cpu.governor);
      
      # Libvirt daemon configuration
      virtualisation.libvirtd = {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";
        
        # QEMU configuration
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          verbatimConfig = ''
            namespaces = []
            user = "${cfg.username}"
          '';
          swtpm.enable = cfg.libvirt.enableTpm;
          ovmf = mkIf cfg.libvirt.enableOvmf {
            enable = true;
            packages = [(pkgs.OVMF.override {
              secureBoot = cfg.libvirt.enableSecureBoot;
              tpmSupport = cfg.libvirt.enableTpm;
            }).fd];
          };
        };
      };
      
      # Hardware support
      hardware.graphics.enable = mkIf cfg.vfio.enable true;
    
      # Additional packages for VFIO/GPU passthrough
      environment.systemPackages = mkMerge [
        (mkIf (cfg.vfio.enable) [
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
        ])
        (mkIf (cfg.vfio.enable && cfg.vfio.singleGpuPassthrough) [
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
        ])
      ];
    }
  ]);
} 
