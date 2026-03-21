# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, stateVersion, hostname, username, ... }: let
in {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ../PCs.nix
  ];

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  boot.kernelModules = [ "kvm-intel" ];

  environment.systemPackages = let
  in
  with pkgs; [
    ntfs3g
    mesa-demos
    pciutils
    mesa
  ];

  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = true;
  #   package = pkgs.virtualbox;
  #   # users.extraGroups.vboxusers.members = [ "birdee" ];
  # };
  # virtualisation.docker.enableNvidia = pkgs.lib.mkIf (config.virtualisation.docker.enable == true) true;

  virtualisation.vmware.host.enable = true;
  virtualisation.vmware.host.package = pkgs.vmware-workstation.override (prev: let
    new_pkgs = import inputs.nixpkgsLocked {
      inherit (pkgs) overlays config;
      inherit (pkgs.stdenv.hostPlatform) system;
    };
  in { gdbm = new_pkgs.gdbm; });
  # virtualisation.vmware.host.extraConfig = ''
  #   # Allow unsupported device's OpenGL and Vulkan acceleration for guest vGPU
  #   mks.gl.allowUnsupportedDrivers = "TRUE"
  #   mks.vk.allowUnsupportedDevices = "TRUE"
  # '';

  services.auto-cpufreq.enable = true;
  services.thermald.enable = true;

  services.asusd.enable = true;
  services.asusd.enableUserService = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  #Nouveau doesn't work at all on this model.
  boot.kernelParams = [ "nouveau.modeset=0" /* "nvidia-drm.modeset=1" */ ];
  boot.blacklistedKernelModules = [ "nouveau"];

  nixpkgs.config.nvidia.acceptLicense = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    prime = {
      sync.enable = true;
      nvidiaBusId = "PCI:01:00:0";   # Found with lspci | grep VGA
      intelBusId = "PCI:00:02:0";   # Found with lspci | grep VGA
    };
  };

  services.xserver.videoDrivers = [ "modesetting" "nvidia" "intel" ];

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    # driSupport = true;
    enable32Bit = true;
    # setLdLibraryPath = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
    ];
  };

}
