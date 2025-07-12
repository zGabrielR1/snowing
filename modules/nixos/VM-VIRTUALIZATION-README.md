# Enhanced VM Virtualization Module

This module provides comprehensive virtualization support for NixOS, including VFIO/GPU passthrough capabilities. It's designed to be fully optional and configurable.

## Features

- **Basic Virtualization**: virt-manager and VirtualBox support
- **VFIO/GPU Passthrough**: Full PCI passthrough support with KVM/QEMU
- **OVMF Support**: UEFI firmware with Secure Boot and TPM emulation
- **Flexible Configuration**: Multiple options for different use cases
- **Optional Features**: All advanced features are opt-in

## Basic Usage

### Enable Basic virt-manager

```nix
virtualisation.vm = {
  enable = true;
  type = "virt-manager";
  username = "your-username";
};
```

### Enable VirtualBox

```nix
virtualisation.vm = {
  enable = true;
  type = "virtualbox";
  username = "your-username";
};
```

### Enable Both

```nix
virtualisation.vm = {
  enable = true;
  type = "both";
  username = "your-username";
};
```

## VFIO/GPU Passthrough Setup

### Prerequisites

1. **Hardware Requirements**:
   - CPU with Intel VT-d or AMD-Vi support
   - Dedicated GPU for passthrough
   - IOMMU enabled in BIOS/UEFI

2. **Find Your GPU PCI IDs**:
   ```bash
   lspci -nn | grep -i vga
   lspci -nn | grep -i audio
   ```

### Intel-based Setup

```nix
virtualisation.vm = {
  enable = true;
  type = "virt-manager";
  username = "your-username";
  
  vfio = {
    enable = true;
    platform = "intel";
    gpuIds = [
      "10de:2482"  # NVIDIA GPU Graphics
      "10de:228b"  # NVIDIA GPU Audio
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
```

### AMD-based Setup

```nix
virtualisation.vm = {
  enable = true;
  type = "virt-manager";
  username = "your-username";
  
  vfio = {
    enable = true;
    platform = "amd";
    gpuIds = [
      "1002:67b0"  # AMD GPU Graphics
      "1002:aac8"  # AMD GPU Audio
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
```

## Configuration Options

### Main Options

- `enable`: Enable the virtualization module
- `type`: Choose between "virt-manager", "virtualbox", or "both"
- `username`: Username to add to virtualization groups

### VFIO Options

- `vfio.enable`: Enable VFIO/GPU passthrough support
- `vfio.platform`: CPU platform ("intel", "amd", or "none")
- `vfio.gpuIds`: List of GPU PCI IDs to passthrough
- `vfio.blacklistGraphics`: Whether to blacklist graphics drivers
- `vfio.blacklistedDrivers`: Additional drivers to blacklist
- `vfio.loadGraphicsAfterVfio`: Load graphics drivers after VFIO modules
- `vfio.graphicsDrivers`: Graphics drivers to load after VFIO

### Libvirt Options

- `libvirt.enableOvmf`: Enable OVMF (UEFI firmware) support
- `libvirt.enableSecureBoot`: Enable Secure Boot in OVMF
- `libvirt.enableTpm`: Enable TPM emulation
- `libvirt.enableSpice`: Enable SPICE USB redirection

## Advanced Configurations

### Host Graphics with GPU Passthrough

If you want to use an iGPU for the host and passthrough a dedicated GPU:

```nix
virtualisation.vm = {
  enable = true;
  type = "virt-manager";
  username = "your-username";
  
  vfio = {
    enable = true;
    platform = "intel";
    gpuIds = [
      "10de:2482"  # Dedicated GPU for passthrough
      "10de:228b"
    ];
    blacklistGraphics = false;  # Don't blacklist
    loadGraphicsAfterVfio = true;
    graphicsDrivers = [ "i915" ];  # Intel iGPU for host
  };
};
```

### Minimal VFIO Setup

Just enable IOMMU without GPU passthrough:

```nix
virtualisation.vm = {
  enable = true;
  type = "virt-manager";
  username = "your-username";
  
  vfio = {
    enable = true;
    platform = "intel";  # or "amd"
    # No GPU IDs specified
  };
};
```

## Troubleshooting

### Check IOMMU Groups

```bash
# Check if IOMMU is enabled
dmesg | grep -i iommu

# List IOMMU groups
find /sys/kernel/iommu_groups/ -type l

# Check PCI devices
lspci -nn
```

### Verify VFIO Modules

```bash
# Check loaded modules
lsmod | grep vfio

# Check if GPU is bound to vfio-pci
lspci -nnk | grep -A 2 -B 2 vfio
```

### Common Issues

1. **IOMMU not enabled**: Check BIOS/UEFI settings
2. **GPU not bound to vfio-pci**: Ensure correct PCI IDs and blacklisting
3. **Permission denied**: Ensure user is in libvirtd group
4. **VM won't start**: Check OVMF configuration and Secure Boot settings

## Additional Tools

The module provides these additional packages when VFIO is enabled:

- `qemu-system-x86_64-uefi`: Convenience script for QEMU with UEFI
- OVMF firmware packages
- Additional virtualization tools

## Migration from Old Configuration

If you had the old commented configuration in `default.nix`, simply uncomment it and update to the new format:

```nix
# Old format (remove this)
/*
virtualisation.vm = {
  enable = true;
  type = "virt-manager";
  username = "zrrg"; 
};
*/

# New format (use this)
virtualisation.vm = {
  enable = true;
  type = "virt-manager";
  username = "zrrg";
  # Add VFIO options as needed
};
``` 