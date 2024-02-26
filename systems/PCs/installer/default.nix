{ config, lib, pkgs, self, system-modules, inputs, nixpkgs, ... }: {
  imports = with system-modules; [
    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    birdeeVim.module
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
      IFS='@' read -ra parts <<< "$1"
      hostname="${parts[1]}"
      username="${parts[2]}"
      sudo nix run github:nix-community/disko -- --mode disko --flake github:BirdeeHub/birdeeSystems#$hostname
      sudo nixos-install --flake github:BirdeeHub/birdeeSystems#$hostname
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username
      git clone https://github.com/BirdeeHub/birdeeSystems /mnt/home/birdee/birdeeSystems
    ''}";
    disko-birdee = "${pkgs.writeShellScript "disko-birdee" ''
      sudo nix run github:nix-community/disko -- --mode disko --flake github:BirdeeHub/birdeeSystems#$1
    ''}";
    install-birdeeOS = "${pkgs.writeShellScript "install-birdeeOS" ''
      IFS='@' read -ra parts <<< "$1"
      hostname="${parts[1]}"
      username="${parts[2]}"
      sudo nixos-install --flake github:BirdeeHub/birdeeSystems#$hostname
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username
      git clone https://github.com/BirdeeHub/birdeeSystems /mnt/home/birdee/birdeeSystems
    ''}";
    ls = "ls --color=tty";
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

  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.disableWhileTyping = true;
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
    exfatprogs
    _7zz
    lshw
    xclip
  ]);

}
