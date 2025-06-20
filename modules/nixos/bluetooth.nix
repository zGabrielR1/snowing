{ config, pkgs, lib, ... }:

{
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;
}
