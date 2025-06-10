{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.vm;
  
  vmType = types.enum [ "virt-manager" "virtualbox" "both" ];
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
  };

  config = mkIf cfg.enable {
    # virt-manager configuration
    programs.virt-manager.enable = mkIf (cfg.type == "virt-manager" || cfg.type == "both") true;
    
    users.groups.libvirtd.members = mkIf (cfg.type == "virt-manager" || cfg.type == "both") [ cfg.username ];
    
    virtualisation.libvirtd.enable = mkIf (cfg.type == "virt-manager" || cfg.type == "both") true;
    
    virtualisation.spiceUSBRedirection.enable = mkIf (cfg.type == "virt-manager" || cfg.type == "both") true;
    
    # VirtualBox configuration
    virtualisation.virtualbox.host.enable = mkIf (cfg.type == "virtualbox" || cfg.type == "both") true;
    
    users.extraGroups.vboxusers.members = mkIf (cfg.type == "virtualbox" || cfg.type == "both") [ cfg.username ];
    
    virtualisation.virtualbox.host.enableExtensionPack = mkIf (cfg.type == "virtualbox" || cfg.type == "both") true;
  };
} 