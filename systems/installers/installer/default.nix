{ config, lib, pkgs, self, modulesPath, system-modules, inputs, ... }: {
  imports = with system-modules; [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    birdeeVim
    shell.bash
    shell.zsh
    shell.fish
  ];

  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow flakes and new command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.shellAliases = {
    birdeeOS = "${pkgs.writeShellScript "birdeeOS" ''
      hostname=$1
      username=$2
      sudo nix run github:nix-community/disko -- --mode disko --flake github:BirdeeHub/birdeeSystems#$hostname
      sudo nixos-install --flake github:BirdeeHub/birdeeSystems#$hostname
      echo "please set password for user $username"
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username
      git clone https://github.com/BirdeeHub/birdeeSystems /mnt/home/$username/birdeeSystems
    ''}";
    disko-birdee = "${pkgs.writeShellScript "disko-birdee" ''
      sudo nix run github:nix-community/disko -- --mode disko --flake github:BirdeeHub/birdeeSystems#$1
    ''}";
    install-birdeeOS = "${pkgs.writeShellScript "install-birdeeOS" ''
      hostname=$1
      username=$2
      sudo nixos-install --flake github:BirdeeHub/birdeeSystems#$hostname
      echo "please set password for user $username"
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username
      git clone https://github.com/BirdeeHub/birdeeSystems /mnt/home/$username/birdeeSystems
    ''}";
    lsnc = "lsd --color=never";
    la = "ls -a";
    ll = "ls -l";
    l  = "ls -alh";
  };

  isoImage.contents = lib.mkIf (builtins.isPath "${self}/secrets") [
    { source = "${self}/secrets"; target = "/secrets";}
  ];

  isoImage.isoBaseName = "birdeeSystems_installer";

  birdeeMods = {
    zsh.enable = true;
    bash.enable = true;
    fish.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

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

  birdeeVim = {
    enable = true;
    packageNames = [ "noAInvim" ];
  };

  services.libinput.enable = true;
  services.libinput.touchpad.disableWhileTyping = true;
  environment.systemPackages = (let
    ranger = pkgs.stdenv.mkDerivation (let
      rifle = ''${pkgs.ranger}/bin/rifle'';
      ranger_commands = pkgs.writeText "nixRangerRC.conf" (let
        dragon = ''${pkgs.xdragon}/bin/dragon'';
      in ''
        map <C-Y> shell ${dragon} -a -x %p
        map y<C-Y> shell ${dragon} --all-compact -x %p
        set mouse_enabled!
        map ps shell echo "$(xclip -o) ." | xargs cp -r
      '');
      rangerBinScript = pkgs.writeScript "ranger" ''
        #!${pkgs.bash}/bin/bash
        ${pkgs.ranger}/bin/ranger --cmd='source ${ranger_commands}' "$@"
      '';
      ranger_desktop = pkgs.writeText "ranger.desktop" (/*desktop*/''
        [Desktop Entry]
        Type=Application
        Name=ranger
        Comment=Launches the ranger file manager
        Icon=utilities-terminal
        Terminal=false
        Exec=alacritty -e ranger
        Categories=ConsoleOnly;System;FileTools;FileManager
        MimeType=inode/directory;
        Keywords=File;Manager;Browser;Explorer;Launcher;Vi;Vim;Python
      '');
    in {
      name = "ranger";
      builder = pkgs.writeText "builder.sh" (/*bash*/''
        source $stdenv/setup
        mkdir -p $out/bin
        mkdir -p $out/share/applications
        cp ${rangerBinScript} $out/bin/ranger
        cp ${rifle} $out/bin/rifle
        cp ${ranger_desktop} $out/share/applications/ranger.desktop
      '');
    });
  in with pkgs; [
    ranger
    git
    xsel
    ntfs3g
    findutils
    exfat
    clamav
    chkrootkit
    lynis
    exfatprogs
    _7zz
    lshw
    xclip
    dislocker
  ]);

}
