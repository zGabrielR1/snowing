# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./user-configuration.nix
      ../../modules/nixos/hyprland.nix
      ../../modules/nixos/nix-settings.nix
      ../../modules/nixos/flatpak.nix
      ../../users
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_testing;
  # boot.readOnlyNixStore = false;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system - but minimize what gets pulled in
  #services.xserver.enable = true;
  
  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [
    "incusbr0" 
    "docker0" 
];

  # Enable SDDM with Makima theme
  #custom.sddm-theme.enable = true;

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  # Alternative display managers (commented out)
  #services.displayManager.sddm.enable = true;

  # Alternative desktop managers (commented out)
  #services.desktopManager.plasma6.enable = true;
  #services.xserver.desktopManager.xfce.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;
  #services.desktopManager.cinnamon.enable = true;
  #services.xserver.desktopManager.budgie.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  # Make shebang work.
  services.envfs.enable = true;

  # Enable sound with pipewire.

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.zrrg = {
    isNormalUser = true;
    description = "Gabriel Renostro";
    extraGroups = [ "networkmanager" "wheel" "incus-admin" "podman" "docker" ];
    /*
    subGidRanges = [
        {
            count = 65536;
            startGid = 1000;
        }
    ];
    subUidRanges = [
        {
            count = 65536;
            startUid = 1000;
        }
    ];
    */
    # System-level packages for user are less common with HM, keep this minimal or empty
    # packages = with pkgs; [ ];
  };

  # Define Home Manager configuration for the user 'zrrg'
  home-manager = {
    # This is where you list users managed by Home Manager
    users.zrrg = {
      imports = [
        # This is the main entry point for zrrg's Home Manager config
        ../../modules/home/profiles/zrrg/default.nix
      ];
      # You can also set Home Manager options directly here if needed, e.g.:
      # home.username = "zrrg";
      # home.homeDirectory = "/home/zrrg";
    };

    # Pass special arguments to all Home Manager modules for all users
    extraSpecialArgs = {
      inherit inputs; # This passes the 'inputs' from your flake to your HM modules
      system = "x86_64-linux"; # Pass the system architecture
      # You could also pass 'self' from the flake if needed:
      # self = inputs.self; # Assuming 'self' was passed to specialArgs in flake.nix
                           # Your flake.nix does: specialArgs = { inherit inputs self; }
                           # So you could do:
      # inherit inputs self;
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Enable nix-ld with all necessary libraries
  custom.nix-ld.enable = true;

  # Enable AppImage support with binfmt
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  services.flatpak-apps = {
  flatseal.enable = true;
  kontainer.enable = true;
};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
}
