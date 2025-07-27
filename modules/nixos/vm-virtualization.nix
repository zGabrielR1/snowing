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
    # "vfio_virqfd"  # Not available in all kernel versions
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
    
    users.groups.libvirtd.members = mkIf (cfg.type == "virt-manager" || cfg.type == "both") [ cfg.username ];
    
    # Add user to additional groups for VFIO/VM management
    users.users.${cfg.username}.extraGroups = mkIf cfg.vfio.enable [
      "qemu-libvirtd" "libvirtd" "disk"
    ];
    
    virtualisation.spiceUSBRedirection.enable = mkIf (cfg.type == "virt-manager" || cfg.type == "both") cfg.libvirt.enableSpice;
    
    # VirtualBox configuration
    virtualisation.virtualbox.host.enable = mkIf (cfg.type == "virtualbox" || cfg.type == "both") true;
    
    users.extraGroups.vboxusers.members = mkIf (cfg.type == "virtualbox" || cfg.type == "both") [ cfg.username ];
    
    virtualisation.virtualbox.host.enableExtensionPack = mkIf (cfg.type == "virtualbox" || cfg.type == "both") true;
    
    # VFIO/GPU Passthrough Configuration
    boot.initrd.kernelModules = mkIf cfg.vfio.enable (vfioModules ++ 
      (lib.optionals cfg.vfio.loadGraphicsAfterVfio cfg.vfio.graphicsDrivers));
    
    boot.kernelParams = mkIf cfg.vfio.enable (
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
      ])
    );
    
    boot.blacklistedKernelModules = mkIf (cfg.vfio.enable && cfg.vfio.blacklistGraphics) 
      (cfg.vfio.blacklistedDrivers ++ [ "amdgpu" "radeon" "nouveau" ]);
    
    # Extra modprobe config for VFIO-PCI IDs
    boot.extraModprobeConfig = mkIf cfg.vfio.enable (
      lib.optionalString (cfg.vfio.gpuIds != [])
        ("options vfio-pci ids=" + lib.concatStringsSep "," cfg.vfio.gpuIds)
    );
    
    # Enhanced libvirt configuration with OVMF
    virtualisation.libvirtd = mkIf (cfg.type == "virt-manager" || cfg.type == "both") {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      #qemu.ovmf.enable = true;
      qemu.runAsRoot = true;
      qemu = {
        package = pkgs.qemu_kvm;
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
      (mkIf (cfg.vfio.enable && (cfg.type == "virt-manager" || cfg.type == "both")) [
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
      (mkIf cfg.vfio.singleGpuPassthrough [
        # Script to handle single GPU passthrough with dynamic detection
        (pkgs.writeShellScriptBin "single-gpu-passthrough" ''
          #!/bin/bash
          # Single GPU passthrough helper script with dynamic GPU detection
          
          # Colors for output
          RED='\033[0;31m'
          GREEN='\033[0;32m'
          YELLOW='\033[1;33m'
          BLUE='\033[0;34m'
          NC='\033[0m' # No Color
          
          # Dynamic GPU detection functions
          get_gpu_pci_ids() {
            lspci -nn | grep -i vga | awk '{print $1}' | sed 's/:/\\:/g'
          }
          
          get_audio_pci_ids() {
            lspci -nn | grep -i audio | awk '{print $1}' | sed 's/:/\\:/g'
          }
          
          get_gpu_info() {
            lspci -nn | grep -i vga
          }
          
          get_audio_info() {
            lspci -nn | grep -i audio
          }
          
          # Function to check if device is bound to a driver
          is_device_bound() {
            local pci_id="$1"
            local driver_path="/sys/bus/pci/devices/$pci_id/driver"
            [[ -L "$driver_path" ]]
          }
          
          # Function to get current driver
          get_current_driver() {
            local pci_id="$1"
            local driver_path="/sys/bus/pci/devices/$pci_id/driver"
            if [[ -L "$driver_path" ]]; then
              basename "$(readlink "$driver_path")"
            else
              echo "none"
            fi
          }
          
          # Function to safely unbind device
          safe_unbind() {
            local pci_id="$1"
            local driver_name="$2"
            
            if is_device_bound "$pci_id"; then
              local current_driver=$(get_current_driver "$pci_id")
              if [[ "$current_driver" == "$driver_name" ]]; then
                echo "$pci_id" > "/sys/bus/pci/devices/$pci_id/driver/unbind" 2>/dev/null
                if [[ $? -eq 0 ]]; then
                  echo -e "${GREEN}✓${NC} Unbound $pci_id from $driver_name"
                else
                  echo -e "${RED}✗${NC} Failed to unbind $pci_id from $driver_name"
                  return 1
                fi
              else
                echo -e "${YELLOW}⚠${NC} $pci_id is bound to $current_driver, not $driver_name"
              fi
            else
              echo -e "${BLUE}ℹ${NC} $pci_id is not bound to any driver"
            fi
          }
          
          # Function to safely bind device
          safe_bind() {
            local pci_id="$1"
            local driver_name="$2"
            
            echo "$pci_id" > "/sys/bus/pci/drivers/$driver_name/bind" 2>/dev/null
            if [[ $? -eq 0 ]]; then
              echo -e "${GREEN}✓${NC} Bound $pci_id to $driver_name"
            else
              echo -e "${RED}✗${NC} Failed to bind $pci_id to $driver_name"
              return 1
            fi
          }
          
          case "$1" in
            "start")
              echo -e "${BLUE}🚀 Preparing for single GPU passthrough...${NC}"
              echo
              
              # Show current GPU information
              echo -e "${YELLOW}Current GPU devices:${NC}"
              get_gpu_info | while read line; do
                echo "  $line"
              done
              echo
              
              echo -e "${YELLOW}Current audio devices:${NC}"
              get_audio_info | while read line; do
                echo "  $line"
              done
              echo
              
              # Process GPU devices
              local gpu_error=false
              for gpu in $(get_gpu_pci_ids); do
                echo -e "${BLUE}Processing GPU: $gpu${NC}"
                if ! safe_unbind "$gpu" "${cfg.vfio.hostGraphicsDriver}"; then
                  gpu_error=true
                fi
                if ! safe_bind "$gpu" "vfio-pci"; then
                  gpu_error=true
                fi
                echo
              done
              
              # Process audio devices
              for audio in $(get_audio_pci_ids); do
                echo -e "${BLUE}Processing audio: $audio${NC}"
                if ! safe_unbind "$audio" "${cfg.vfio.hostGraphicsDriver}"; then
                  gpu_error=true
                fi
                if ! safe_bind "$audio" "vfio-pci"; then
                  gpu_error=true
                fi
                echo
              done
              
              if [[ "$gpu_error" == "true" ]]; then
                echo -e "${RED}❌ Some devices failed to bind to vfio-pci${NC}"
                echo -e "${YELLOW}You may need to check your configuration or reboot${NC}"
                exit 1
              else
                echo -e "${GREEN}✅ All GPUs successfully bound to vfio-pci${NC}"
              fi
              ;;
              
            "stop")
              echo -e "${BLUE}🔄 Restoring GPU to host...${NC}"
              echo
              
              # Process GPU devices
              local gpu_error=false
              for gpu in $(get_gpu_pci_ids); do
                echo -e "${BLUE}Processing GPU: $gpu${NC}"
                if ! safe_unbind "$gpu" "vfio-pci"; then
                  gpu_error=true
                fi
                if ! safe_bind "$gpu" "${cfg.vfio.hostGraphicsDriver}"; then
                  gpu_error=true
                fi
                echo
              done
              
              # Process audio devices
              for audio in $(get_audio_pci_ids); do
                echo -e "${BLUE}Processing audio: $audio${NC}"
                if ! safe_unbind "$audio" "vfio-pci"; then
                  gpu_error=true
                fi
                if ! safe_bind "$audio" "${cfg.vfio.hostGraphicsDriver}"; then
                  gpu_error=true
                fi
                echo
              done
              
              if [[ "$gpu_error" == "true" ]]; then
                echo -e "${RED}❌ Some devices failed to restore to host${NC}"
                echo -e "${YELLOW}You may need to check your configuration or reboot${NC}"
                exit 1
              else
                echo -e "${GREEN}✅ All GPUs successfully restored to host${NC}"
              fi
              ;;
              
            "status")
              echo -e "${BLUE}📊 GPU Passthrough Status${NC}"
              echo
              
              echo -e "${YELLOW}GPU devices:${NC}"
              for gpu in $(get_gpu_pci_ids); do
                local driver=$(get_current_driver "$gpu")
                local status_color=$([[ "$driver" == "vfio-pci" ]] && echo "$GREEN" || echo "$RED")
                echo -e "  $gpu: ${status_color}$driver${NC}"
              done
              
              echo -e "${YELLOW}Audio devices:${NC}"
              for audio in $(get_audio_pci_ids); do
                local driver=$(get_current_driver "$audio")
                local status_color=$([[ "$driver" == "vfio-pci" ]] && echo "$GREEN" || echo "$RED")
                echo -e "  $audio: ${status_color}$driver${NC}"
              done
              ;;
              
            "info")
              echo -e "${BLUE}ℹ GPU Information${NC}"
              echo
              echo -e "${YELLOW}GPU devices:${NC}"
              get_gpu_info
              echo
              echo -e "${YELLOW}Audio devices:${NC}"
              get_audio_info
              echo
              echo -e "${YELLOW}IOMMU groups:${NC}"
              find /sys/kernel/iommu_groups/ -type l 2>/dev/null | head -20
              ;;
              
            *)
              echo -e "${BLUE}Single GPU Passthrough Helper Script${NC}"
              echo
              echo "Usage: single-gpu-passthrough {start|stop|status|info}"
              echo
              echo "Commands:"
              echo -e "  ${GREEN}start${NC}  - Prepare GPU for passthrough (bind to vfio-pci)"
              echo -e "  ${RED}stop${NC}   - Restore GPU to host (bind to ${cfg.vfio.hostGraphicsDriver})"
              echo -e "  ${BLUE}status${NC} - Show current binding status"
              echo -e "  ${YELLOW}info${NC}   - Show detailed GPU and IOMMU information"
              echo
              echo "This script dynamically detects GPU and audio devices and handles"
              echo "binding/unbinding them for single GPU passthrough scenarios."
              ;;
          esac
        '')
      ])
    ];
  };
} 
