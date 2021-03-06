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

  boot = {
     kernelPackages = pkgs.linuxPackages_4_3;
     kernelParams = [
      # https://help.ubuntu.com/community/AppleKeyboard
      # https://wiki.archlinux.org/index.php/Apple_Keyboard
      "hid_apple.fnmode=1"
      "hid_apple.iso_layout=0"
      "hid_apple.swap_opt_cmd=1"
      ];
    loader = {
      gummiboot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModprobeConfig = ''
      options libata.force=noncq
      options resume=/dev/sda5
      options snd_hda_intel index=0 model=intel-mac-auto id=PCH
      options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
     '';
  };

  networking = {
     hostName = "nixos"; # Define your hostname.
     networkmanager.enable = true;
     interfaceMonitor.enable = true;
  };

  # fonts
  fonts = {
    enableFontDir = true;
    enableCoreFonts = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      inconsolata
      liberation_ttf
      dejavu_fonts
      bakoma_ttf
      gentium
      ubuntu_font_family
      terminus_font
    ];
  };

  nix = {
    useChroot = true;
    trustedBinaryCaches = [ http://hydra.nixos.org ];
    binaryCaches = [
      http://cache.nixos.org
      http://hydra.nixos.org
    ];
  };

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

  emacspkgs = pkgs.emacsWithPackages
      (epkgs: with epkgs; [
	ace-jump-mode
	auctex
	company
	company-ghc
	diminish
	flycheck
	ghc
	git-auto-commit-mode
	git-timemachine
	haskell-mode
	helm
	idris-mode
	ido-ubiquitos
	ido-vertical-mode
	pkgs.ledger
	magit
	markdown-mode
	monokai-theme
	org-plus-contrib
	rainbow-delimiters
	smex
	undo-tree
	use-package
	yasnippet
      ]);

  environment.systemPackages = with pkgs; [
     emacspkgs
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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
     enable = true;
     autorun = false;
     xkbVariant = "mac";
     xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";
     videoDrivers = [ "nvidia" ];
     layout = "us";
     vaapiDrivers = [ pkgs.vaapiIntel ];
     multitouch.enable = true;
     synaptics = {
       enable = true;
       tapButtons = true;
       fingersMap = [ 0 0 0 ];
       buttonsMap = [ 1 3 2 ];
       twoFingerScroll = true;
    };
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  # custom setup for emacs, use emacsclient
  systemd.user.services.emacs = {
    description = "Emacs: the extensible, self-documenting text editor";
    serviceConfig = {
      Type      = "forking";
      ExecStart = "${pkgs.emacs}/bin/emacs --daemon";
      ExecStop  = "${pkgs.emacs}/bin/emacsclient --eval (kill-emacs)";
      Restart   = "always";
    };

    #emacs overrides
    packageOverrides = pkgs: {
	# Define my own Emacs
	emacs = pkgs.lib.overrideDerivation (pkgs.emacs.override {
	    # Use gtk3 instead of the default gtk2
	    gtk = pkgs.gtk3;
	    # Make sure imagemgick is a dependency because I regularly
	    # look at pictures from Emasc
	    imagemagick = pkgs.imagemagickBig;
	  }) (attrs: {
	    # I don't want emacs.desktop file because I only use
	    # emacsclient.
	    postInstall = attrs.postInstall + ''
	      rm $out/share/applications/emacs.desktop
	    '';
	});

    };

  hardware.opengl.driSupport32Bit = true;

  powerManagement.enable = true;
  programs.light.enable = true;
  
  #zsh
  programs.zsh.enable = true;
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

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

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql94;
    authentication = "local all all ident";
  };
}
