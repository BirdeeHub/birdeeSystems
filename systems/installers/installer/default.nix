{ config, lib, pkgs, self, modulesPath, system-modules, inputs, ... }: {
  imports = with system-modules; [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    birdeevim
    shell.bash
    shell.zsh
    shell.fish
  ];

  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow flakes and new command
  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
  nix.settings.show-trace = true;

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
    noto-fonts-color-emoji
    nerd-fonts.fira-mono
    nerd-fonts.go-mono
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

  birdeevim = {
    enable = true;
    packageNames = [ "noAInvim" ];
  };

  services.libinput.enable = true;
  services.libinput.touchpad.disableWhileTyping = true;
  environment.systemPackages = with pkgs; [
    xplr
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
    # dislocker
  ];

}
