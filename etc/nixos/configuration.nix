# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_4_3;
  boot.kernelParams = [
    # https://help.ubuntu.com/community/AppleKeyboard
    # https://wiki.archlinux.org/index.php/Apple_Keyboard
    "hid_apple.fnmode=1"
    "hid_apple.iso_layout=0"
    "hid_apple.swap_opt_cmd=1"
  ];


  boot.extraModprobeConfig = ''
   options libata.force=noncq
   options resume=/dev/sda5
   options snd_hda_intel index=0 model=intel-mac-auto id=PCH
   options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
  '';
  
  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;  
  networking.interfaceMonitor.enable = true;

  # fonts
  fonts = {
    enableFontDir = true;
    enableCoreFonts = true;
    enableGhostscriptFonts = true;
  };

   fonts.fonts = with pkgs; [
    corefonts
    inconsolata
    liberation_ttf
    dejavu_fonts
    bakoma_ttf
    gentium
    ubuntu_font_family
    terminus_font
  ];

  nix.useChroot = true;
  nix.trustedBinaryCaches = [ http://hydra.nixos.org ];
  nix.binaryCaches =
    [
      http://cache.nixos.org
      http://hydra.nixos.org
    ];

  # Select internationalisation properties.
   i18n = {
     consoleFont = "sun12x22";
     consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
   };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     emacs
     chromium
     ghc
     skype
     vlc
     nixops
     htop
     zsh
     spotify
     nmap
   ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.autorun = false;
  services.xserver.xkbVariant = "mac";
  services.xserver.xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.vaapiDrivers = [ pkgs.vaapiIntel ];
  hardware.opengl.driSupport32Bit = true;

  powerManagement.enable = true;
  programs.light.enable = true;

  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";
  services.xserver.multitouch.enable = true;
  services.xserver.synaptics = {
    enable = true;
    tapButtons = true;
    fingersMap = [ 0 0 0 ];
    buttonsMap = [ 1 3 2 ];
    twoFingerScroll = true;
  };

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.dmj = {
    isNormalUser = true;
    group = "users";
    extraGroups = ["sudo" "networkmanager" "wheel" ];
    uid = 1000;
    createHome = true;
    home = "/home/dmj";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql94;
  services.postgresql.authentication = "local all all ident";
}
