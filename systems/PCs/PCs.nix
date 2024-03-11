# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, inputs, stateVersion, users, hostname, system-modules, overlays, ... }: let
in {
  imports = with system-modules; [
    i3
    birdeeVim.module
    term.alacritty
    shell.bash
    shell.zsh
    shell.fish
    lightdm
    i3MonMemory
    LD
  ];

  birdeeVim = {
    enable = true;
    packageNames = [ "noAInvim" ];
  };

  users.users = users.users;
  birdeeMods = {
    i3.enable = true;
    i3.tmuxDefault = true;
    zsh.enable = true;
    bash.enable = true;
    fish.enable = true;
    alacritty.enable = true;
    lightdm.enable = true;
    i3MonMemory.enable = true;
    LD.enable = true;
  };
  nixpkgs.config.permittedInsecurePackages = [
    "nix-2.16.2"
  ];
  # nix.extraOptions = ''
  #   plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
  #   extra-builtins-file = ${./.}
  # '';

  services.flatpak.enable = true;

  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  virtualisation.libvirtd.enable = true;

  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;
  services.clamav.updater.interval = "weekly";

  environment.variables = {
  };
  environment.interactiveShellInit = ''
  '';
  environment.shellAliases = {
    ls = "lsd";
    la = "lsd -a";
    ll = "lsd -l";
    l  = "lsd -alh";
  };

  # Bootloader.
  boot.loader.timeout = 3;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname; # Define your hostname.
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
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "-d";
    persistent = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ gutenprint hplip splix ];

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

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.disableWhileTyping = true;
  # services.xserver.synaptics.enable = true;
  # services.xserver.synaptics.palmDetect = true;
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

  virtualisation.docker.enable = true;

  users.defaultUserShell = pkgs.zsh;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (let
  in
  with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    hplip
    qemu
    fuse
    fuse3
    parted
    gparted
    sshfs-fuse
    socat
    screen
    tcpdump
    sdparm
    hdparm
    smartmontools # for diagnosing hard disks
    nix-info
    pciutils
    lm_sensors
    usbutils
    nvme-cli
    unzip
    zip
    vagrant
    exfat
    exfatprogs
    lshw
    lsd
    bat
    wget
    tree
    zip
    _7zz
    unzip
    xclip
    xsel
    git
    ntfs3g
  ]);

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

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
  system.stateVersion = stateVersion; # Did you read the comment?

}
