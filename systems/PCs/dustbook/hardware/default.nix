{ config, pkgs, lib, self, inputs, stateVersion, users, hostname, ... }: let
in {
  imports = [
    inputs.nixos-hardware.outputs.nixosModules.common-pc-laptop
    inputs.nixos-hardware.outputs.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
  ];
  config = {
    hardware.opengl.extraPackages = with pkgs; [
      vaapiVdpau
    ];
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
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    environment.systemPackages = [ pkgs.glxinfo pkgs.pciutils pkgs.mesa ];
    virtualisation.docker.enableNvidia = pkgs.lib.mkIf (config.virtualisation.docker.enable == true) true;

    boot.kernelParams = [
      "hid_apple.iso_layout=0"
      "nouveau.modeset=0"
    ];

    services.mbpfan.enable = lib.mkDefault true;
  };
}
