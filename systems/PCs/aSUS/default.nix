# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake-path, lib, self, inputs, stateVersion, users, hostname, system-modules, ... }: let
in {
  imports = with system-modules; [
    inputs.nixos-hardware.outputs.nixosModules.common-pc-laptop
    inputs.nixos-hardware.outputs.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ../PCs.nix
  ];

  birdeeMods = {
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  boot.kernelModules = [ "kvm-intel" ];

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
    leftMon = ''${pkgs.writeScript "leftMonFlexible.sh" (/*bash*/''
      #!/usr/bin/env bash
      rate=59.95; mode="1920x1080"; side="l";
      current="HDMI-1"; primary="eDP-1";
      [[ $# > 0 ]] && rate=$1 && shift 1
      [[ $# > 0 ]] && mode=$1 && shift 1
      [[ $# > 0 ]] && side=$1 && shift 1
      [[ $# > 0 ]] && current=$1 && shift 1
      [[ $# > 0 ]] && primary=$1 && shift 1
      if [[ $side == "l" ]]; then
        side="--left-of"
      elif [[ $side == "r" ]]; then
        side="--right-of"
      fi
      xrandr --output $current $side $primary --rate $rate --mode $mode $@
    '')}'';
    leftMonPrf = /*bash*/ "xrandr --output HDMI-1 --left-of eDP-1 --preferred";
  };

  environment.systemPackages = let
  in
  with pkgs; [
    ntfs3g
    glxinfo
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
      inherit (pkgs) system overlays config;
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
      vaapiVdpau
    ];
  };

}
