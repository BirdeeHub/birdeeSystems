# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, inputs, stateVersion, username, hostname, ... }: let
    poshTheme = builtins.toFile "atomic-emodipt.omp.json" (builtins.readFile ./term/atomic-emodipt.omp.json);
    zshcmplcfg = builtins.toFile "compinstallOut" (builtins.readFile ./term/compinstallOut);
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
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

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;


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

  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.prime = {
    sync.enable = true;
    nvidiaBusId = "PCI:01:00:0";   # Found with lspci | grep VGA
    intelBusId = "PCI:00:02:0";   # Found with lspci | grep VGA
  };


  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
# boot.blacklistedKernelModules = ["nouveau"];


  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
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
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      configFile = builtins.toFile "config" (''
        set $i3barConfigFile ${builtins.toFile "i3bar" (builtins.readFile ./i3/i3bar)}
        # set $dunstrc ${builtins.toFile "dunstrc" (builtins.readFile ./i3/dunstrc)}
      '' + builtins.readFile ./i3/config + ''
      '');
      extraPackages = let
        # dunstrc = builtins.toFile "dunstrc" (builtins.readFile ./i3/dunstrc);
        # dunst = pkgs.writeScriptBin "dunst" ''
        #   #!/bin/sh
        #   exec ${pkgs.dunst}/bin/dunst -conf ${dunstrc} "$@"
        # '';
        monMover = (pkgs.writeScriptBin "monWkspcCycle.sh"
          (builtins.readFile ./i3/monWkspcCycle.sh));
      in
      with pkgs; [
        monMover
        jq
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        # i3lock #default i3 screen locker
        # dunst
        pa_applet
        pavucontrol
        networkmanagerapplet
        lxappearance
        # i3blocks #if you are planning on using i3blocks over i3status
      ];
    };
  };
  qt.platformTheme = "gtk";
  # uncomment to fix i3blocks
  # environment.pathsToLink = [ "/libexec" ];
  programs.dconf.enable = true;

  users.defaultUserShell = pkgs.zsh;
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };
  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = true;
  # };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
  };

  programs = {
    bash = {
      promptInit = ''
        eval "$(oh-my-posh init bash --config ${poshTheme})"
      '';
    };
    zsh = {
      enable = true;
      autosuggestions = {
        enable = true;
        strategy = [ "history" ];
      };
      interactiveShellInit = ''
        . ${zshcmplcfg}

        # Lines configured by zsh-newuser-install
        HISTFILE=~/.histfile
        HISTSIZE=1000
        SAVEHIST=10000
        setopt extendedglob
        unsetopt autocd nomatch
        bindkey -v
        # End of lines configured by zsh-newuser-install
      '';
      promptInit = ''
        eval "$(oh-my-posh init zsh --config ${poshTheme})"
      '';
    };
    fish = {
      enable = true;
      promptInit = ''
        oh-my-posh init fish --config ${poshTheme} | source
      '';
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = let
    alakittycfg = builtins.toFile "alacritty.yml" (builtins.readFile ./term/alacritty.yml);
    alakitty = pkgs.writeScriptBin "alacritty" ''
      #!/bin/sh
      exec ${pkgs.alacritty}/bin/alacritty --config-file ${alakittycfg} "$@"
    '';
  in
  with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    alakitty
    pciutils
    glxinfo
    lshw
    wget
    tree
    zip
    unzip
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
  system.stateVersion = stateVersion; # Did you read the comment?

}
