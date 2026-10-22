# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, config, lib, pkgs, inputs, hostname, output-name, ... }: let
in {
  birdeeMods = {
    bash.enable = true;
    flatpak.enable = true;
    lightdm.enable = true;
    LD.enable = true;
    nixconfig.enable = true;
    power.enable = true;
    theme.enable = true;
    antivirus.enable = true;
    audio.enable = true;
    bluetooth.enable = true;
    boot.enable = true;
    input.enable = true;
    locale.enable = true;
    networking.enable = true;
    printing.enable = true;
    virtualisation.enable = true;
    gnupg.enable = true;
  };
  wrappers = {
    neovim.enable = true;
    fish.enable = true;
    i3.enable = true;
    i3.i3Monager.enable = true;
    zsh.enable = true;
    zsh.asSystemDefault = true;
    zsh.output-name = output-name;
    wezterm.enable = true;
    tmux.enable = true;
    tmux.utempter = true;
    xplr.enable = true;
    git.enable = true;
    opencode.enable = false;
    nushell.enable = false;
    luakit.enable = false;
    ranger.enable = false;
  };
  environment.systemPackages = with pkgs; [
    qemu
    fuse
    fuse3
    parted
    gparted
    sshfs-fuse
    socat
    nix-output-monitor
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
    ntfs3g
    # dislocker
    man-pages
    man-pages-posix
  ];
}
