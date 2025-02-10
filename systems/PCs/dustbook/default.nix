# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, self, flake-path, inputs, stateVersion, users, hostname, system-modules, ... }: let
in {
  imports = with system-modules; [
    ../PCs.nix
    inputs.nixos-hardware.outputs.nixosModules.common-pc-laptop
    inputs.nixos-hardware.outputs.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    ./hardware-configuration.nix
  ];

  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = true;
  #   # users.extraGroups.vboxusers.members = [ "birdee" ];
  # };

  nixpkgs.overlays = [
    (final: prev: {
      nerd-fonts = {
        go-mono = prev.nerdfonts.override { fonts = [ "Go-Mono" ]; };
        fira-mono = prev.nerdfonts.override { fonts = [ "FiraMono" ]; };
      };
    })
  ];

  birdeeMods = {
    lightdm.sessionCommands = ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
        Xft.dpi: 80
      ''}
    '';
  };

  boot.kernelModules = [ "kvm-intel" ];

  environment.systemPackages = let
  in
  with pkgs; [
    glxinfo
    pciutils
    mesa
  ];

  environment.shellAliases = {
    me-build-system = ''${pkgs.writeShellScript "me-build-system" ''
      export FLAKE="${flake-path}";
      exec ${self}/scripts/system "$@"
    ''}'';
    me-build-home = ''${pkgs.writeShellScript "me-build-home" ''
      export FLAKE="${flake-path}";
      exec ${self}/scripts/home "$@"
    ''}'';
    me-build-both = ''${pkgs.writeShellScript "me-build-both" ''
      export FLAKE="${flake-path}";
      exec ${self}/scripts/both "$@"
    ''}'';
  };

  services.auto-cpufreq.enable = true;
  services.thermald.enable = true;

  boot.kernelPackages = pkgs.linuxPackages;
  nixpkgs.config.nvidia.acceptLicense = true;
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "modesetting" "nvidia" "intel" ];
  hardware.nvidia.prime = {
    sync.enable = true;
    nvidiaBusId = "PCI:01:00:0";   # Found with lspci | grep VGA
    intelBusId = "PCI:00:02:0";   # Found with lspci | grep VGA
  };
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau libva
    ];
  };

  # virtualisation.docker.enableNvidia = pkgs.lib.mkIf (config.virtualisation.docker.enable == true) true;

  boot.kernelParams = [
    "hid_apple.iso_layout=0"
    "hid_apple.fnmode=2"
    "nouveau.modeset=0"
  ];

  services.mbpfan.enable = lib.mkDefault true;

}
