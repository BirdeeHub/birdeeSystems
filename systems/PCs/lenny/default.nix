# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake-path, lib, self, inputs, stateVersion, users, hostname, system-modules, ... }: let
in {
  imports = with system-modules; [
    ./hardware-configuration.nix
    ../PCs.nix
  ];

  boot.kernelModules = [ "kvm-amd" ];

  birdeeMods.i3MonMemory.trigger = "Xlog";

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

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

}
