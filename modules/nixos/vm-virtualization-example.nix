# Example configurations for the enhanced vm-virtualization.nix module
# This file shows different usage scenarios - copy the relevant section to your configuration

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # SCENARIO 1: Basic virt-manager setup (no VFIO)
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
  };
  */

  # ============================================================================
  # SCENARIO 2: Basic VirtualBox setup
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virtualbox";
    username = "zrrg";
  };
  */

  # ============================================================================
  # SCENARIO 3: Both virt-manager and VirtualBox
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "both";
    username = "zrrg";
  };
  */

  # ============================================================================
  # SCENARIO 4: Intel-based VFIO/GPU Passthrough setup
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
    
    vfio = {
      enable = true;
      platform = "intel";
      gpuIds = [
        "10de:2482"  # NVIDIA RTX 3070 Ti Graphics
        "10de:228b"  # NVIDIA RTX 3070 Ti Audio
      ];
      blacklistGraphics = true;
      blacklistedDrivers = [ "nvidia" "nouveau" ];
    };
    
    libvirt = {
      enableOvmf = true;
      enableSecureBoot = true;
      enableTpm = true;
      enableSpice = true;
    };
  };
  */

  # ============================================================================
  # SCENARIO 5: AMD-based VFIO/GPU Passthrough setup
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
    
    vfio = {
      enable = true;
      platform = "amd";
      gpuIds = [
        "1002:67b0"  # AMD Radeon R9 290X Graphics
        "1002:aac8"  # AMD Radeon R9 290X Audio
      ];
      blacklistGraphics = true;
      blacklistedDrivers = [ "amdgpu" "radeon" ];
    };
    
    libvirt = {
      enableOvmf = true;
      enableSecureBoot = true;
      enableTpm = true;
      enableSpice = true;
    };
  };
  */

  # ============================================================================
  # SCENARIO 6: Advanced setup with host graphics driver loading
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
    
    vfio = {
      enable = true;
      platform = "intel";
      gpuIds = [
        "10de:2482"  # Dedicated GPU for passthrough
        "10de:228b"
      ];
      blacklistGraphics = false;  # Don't blacklist, load after VFIO
      loadGraphicsAfterVfio = true;
      graphicsDrivers = [ "i915" ];  # Intel iGPU for host
    };
    
    libvirt = {
      enableOvmf = true;
      enableSecureBoot = true;
      enableTpm = true;
      enableSpice = true;
    };
  };
  */

  # ============================================================================
  # SCENARIO 7: Minimal VFIO setup (just enable IOMMU)
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
    
    vfio = {
      enable = true;
      platform = "intel";  # or "amd"
      # No GPU IDs specified - just enables IOMMU
    };
  };
  */

  # ============================================================================
  # SCENARIO 8: Custom libvirt configuration
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
    
    vfio = {
      enable = true;
      platform = "intel";
      gpuIds = [ "10de:2482" "10de:228b" ];
      blacklistGraphics = true;
    };
    
    libvirt = {
      enableOvmf = true;
      enableSecureBoot = false;  # Disable Secure Boot
      enableTpm = false;         # Disable TPM
      enableSpice = true;
    };
  };
  */

  # ============================================================================
  # SCENARIO 9: Single GPU Passthrough (NVIDIA)
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
    
    vfio = {
      enable = true;
      platform = "intel";
      singleGpuPassthrough = true;
      hostGraphicsDriver = "i915";  # Intel iGPU for host
      enableVgaSwitcheroo = true;
      # No gpuIds needed - handled dynamically
    };
    
    libvirt = {
      enableOvmf = true;
      enableSecureBoot = true;
      enableTpm = true;
      enableSpice = true;
    };
  };
  */

  # ============================================================================
  # SCENARIO 10: Single GPU Passthrough (AMD)
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
    
    vfio = {
      enable = true;
      platform = "amd";
      singleGpuPassthrough = true;
      hostGraphicsDriver = "amdgpu";  # AMD iGPU for host
      enableVgaSwitcheroo = true;
    };
    
    libvirt = {
      enableOvmf = true;
      enableSecureBoot = true;
      enableTpm = true;
      enableSpice = true;
    };
  };
  */

  # ============================================================================
  # SCENARIO 11: Single GPU Passthrough with Manual Control
  # ============================================================================
  /*
  virtualisation.vm = {
    enable = true;
    type = "virt-manager";
    username = "zrrg";
    
    vfio = {
      enable = true;
      platform = "intel";
      singleGpuPassthrough = true;
      hostGraphicsDriver = "i915";
      enableVgaSwitcheroo = false;  # Manual control only
    };
    
    libvirt = {
      enableOvmf = true;
      enableSecureBoot = true;
      enableTpm = true;
      enableSpice = true;
    };
  };
  */
} 