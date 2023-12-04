# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nestOS"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow flakes and new command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # displayManager.lightdm.enable = true;

    # Enable the i3 Desktop Environment.
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    displayManager = {
      defaultSession = "xfce+i3";
    };
    windowManager.i3 = import ./i3 pkgs;
  };
  qt.platformTheme = "gtk";
  # uncomment to fix i3blocks
  # environment.pathsToLink = [ "/libexec" ];
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  programs.dconf.enable = true;
  fonts.packages = with pkgs; [
    openmoji-color
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraMono" "Go-Mono" ]; })
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "GoMono Nerd Font Mono" ];
      sansSerif = [ "FiraCode Nerd Font Mono" ];
      monospace = [ "FiraCode Nerd Font Mono" ];
      emoji = [ "OpenMoji Color" "OpenMoji" "Noto Color Emoji" ];
    };
  };
  fonts.fontDir.enable = true;
  programs.bash.interactiveShellInit = ''
    eval "$(oh-my-posh init bash --config ${builtins.toFile "atomic-emodipt.omp.json" (builtins.readFile ./atomic-emodipt.omp.json)})"
  '';
  programs.zsh.interactiveShellInit = ''
    eval "$(oh-my-posh init bash --config ${builtins.toFile "atomic-emodipt.omp.json" (builtins.readFile ./atomic-emodipt.omp.json)})"
  '';
  programs.fish.interactiveShellInit = ''
    eval "$(oh-my-posh init bash --config ${builtins.toFile "atomic-emodipt.omp.json" (builtins.readFile ./atomic-emodipt.omp.json)})"
  '';

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
 #  # Enable OpenGL
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  # };
	#
 #  # Load nvidia driver for Xorg and Wayland
 #  services.xserver.videoDrivers = ["nvidia"];
	#
 #  hardware.nvidia = {
	#
 #    # Modesetting is required.
 #    modesetting.enable = true;
	#
 #    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
 #    powerManagement.enable = false;
 #    # Fine-grained power management. Turns off GPU when not in use.
 #    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
 #    powerManagement.finegrained = false;
	#
 #    # Use the NVidia open source kernel module (not to be confused with the
 #    # independent third-party "nouveau" open source driver).
 #    # Support is limited to the Turing and later architectures. Full list of 
 #    # supported GPUs is at: 
 #    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
 #    # Only available from driver 515.43.04+
 #    # Currently alpha-quality/buggy, so false is currently the recommended setting.
 #    open = false;
	#
 #    # Enable the Nvidia settings menu,
	# # accessible via `nvidia-settings`.
 #    nvidiaSettings = true;
	#
 #    # Optionally, you may need to select the appropriate driver version for your specific GPU.
 #    package = config.boot.kernelPackages.nvidiaPackages.stable;
 #  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.birdee = {
    isNormalUser = true;
    description = "birdee";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      signal-desktop
      bitwarden
      bitwarden-cli
      discord
      jdk
      gradle
      kotlin
      kotlin-native
      go
      gimp
      spotify

      chromium
      slack
      zoom-us
    #  thunderbird
    ];
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    bitwarden-cli
    galculator
    qalculate-qt
    alacritty
    pciutils
    glxinfo
    lshw
    wget
    xclip
    xsel
    git
    oh-my-posh
  ];

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
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
