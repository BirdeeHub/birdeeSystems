# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, self, inputs, stateVersion, users, hostname, system-modules, ... }: let
in {
  imports = with system-modules; [
    inputs.nixos-hardware.outputs.nixosModules.common-pc-laptop
    inputs.nixos-hardware.outputs.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
    ../PCs.nix
  ];

  birdeeMods = {
  };

  environment.shellAliases = {
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

  #Nouveau doesn't work at all on this model.
  boot.kernelParams = [ "nouveau.modeset=0" ];
  hardware.opengl.extraPackages = with pkgs; [
    vaapiVdpau
  ];
  services.asusd.enable = true;
  services.asusd.enableUserService = true;

  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "modesetting" "nvidia" "intel" ];
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
  boot.blacklistedKernelModules = [ "nouveau"];

  virtualisation.docker.enableNvidia = pkgs.lib.mkIf (config.virtualisation.docker.enable == true) true;
}
