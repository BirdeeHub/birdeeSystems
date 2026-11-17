# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, hostname, ... }: let
in {
  imports = [
    ../PCs.nix
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  # boot.blacklistedKernelModules = [ "b43" "bcma" "ssb" ];
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-63-6.6.161"
  ];
  # TODO: figure out if there is any way you can use different network drivers
  # b43 when installed in this manner however does not.
  # nixpkgs.config.allowUnfree = true;
  # hardware.enableRedistributableFirmware = true;
  # boot.kernelModules = [ "b43" ];

  birdeeMods = {
    lightdm.sessionCommands = ''
      ${pkgs.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
        Xft.dpi: 80
      ''}
    '';
  };
  birdeeMods.power.thermald = true;

  environment.systemPackages = with pkgs; [
    mesa-demos
    pciutils
    mesa
  ];
  nixpkgs.config.problems.handlers = {
    "gtk+".broken = "warn"; # or "ignore"
  };

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
      libva-vdpau-driver libva
    ];
  };

  # hardware.nvidia-container-toolkit.enable = pkgs.lib.mkIf (config.virtualisation.docker.enable == true) true;

  boot.kernelParams = [
    "hid_apple.iso_layout=0"
    "hid_apple.fnmode=2"
    "nouveau.modeset=0"
  ];

  services.mbpfan.enable = lib.mkDefault true;

}
