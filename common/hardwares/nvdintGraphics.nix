{config, pkgs, lib, ...}: {
  options = { birdeeMods.nvidia = {
      enable = lib.mkEnableOption "nvidia";
    };
  };
  config = lib.mkIf config.birdeeMods.nvidia.enable {
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
