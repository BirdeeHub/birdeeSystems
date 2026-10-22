# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, hostname, output-name, username, ... }: let
in {
  birdeeMods = {
    bash.enable = true;
    lightdm.enable = true;
    LD.enable = true;
    nixconfig.enable = true;
    power.enable = true;
    theme.enable = true;
    antivirus.enable = true;
    audio.enable = true;
    bluetooth.enable = true;
    boot.enable = true;
    boot.type = "grub";
    input.enable = true;
    locale.enable = true;
    networking.enable = true;
    virtualisation.enable = true;
    virtualisation.inVM = true;
    gnupg.enable = true;
  };
  wrappers = {
    neovim.enable = true;
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

  services.openssh.enable = true;

  boot.kernelModules = [ "kvm" ];

  swapDevices = let
    GB = v: v*1024;
  in [ {
    device = "/var/lib/swapfile";
    size = GB 3;
  } ];

  environment.systemPackages = with pkgs; [
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
    chromium
    usbutils
    nvme-cli
    unzip
    zip
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
  ];
}
