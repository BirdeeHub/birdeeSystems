{ config, pkgs, self, inputs, stateVersion, users, hostname, ... }: let
in {
  imports = [
    inputs.nixos-hardware.outputs.nixosModules.common-pc-laptop
    inputs.nixos-hardware.outputs.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
  ];
  config = {
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

    environment.systemPackages = [ pkgs.glxinfo pkgs.pciutils pkgs.mesa ];
    virtualisation.docker.enableNvidia = pkgs.lib.mkIf (config.virtualisation.docker.enable == true) true;
  };
}
