# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake-path, lib, inputs, hostname, ... }: let
in {
  imports = [
    ./hardware-configuration.nix
    ../PCs.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  birdeeMods.power.fixAMDpowerSave = true;
  birdeeMods.ollama.enable = true;
  birdeeMods.ollama.acceleration = "rocm";
  birdeeMods.ollama.rocmVersion = "11.0.2";
  birdeeMods.ollama.loadModels = [ "qwen2.5-coder:7b" "gpt-oss:20b" "qwen3:14b" "qwen3:8b" ];

  services.asusd.enable = true;
  systemd.services.asusd.wantedBy = [ "graphical.target" ];
  systemd.services.asus-shutdown.wantedBy = [ "shutdown.target" ];
  services.asusd.fanCurvesConfig.text = let
    curves = ''
        (
            fan: CPU,
            pwm: (20, 40, 80, 100, 125, 150, 200, 250),
            temp: (40, 50, 55, 60, 65, 70, 80, 90),
            enabled: true,
        ),
        (
            fan: GPU,
            pwm: (20, 40, 80, 100, 125, 150, 200, 250),
            temp: (40, 50, 55, 60, 65, 70, 80, 90),
            enabled: true,
        ),
    '';
  in ''
    (
        profiles: (
            balanced: [
                ${curves}
            ],
            performance: [
                ${curves}
            ],
            quiet: [
                ${curves}
            ],
        ),
    )
  '';

  environment.systemPackages = with pkgs; [
    vulkan-tools
    asusctl
    mesa
    clinfo
    vulkan-headers
    radeontools
    mesa-demos
    rocmPackages.rocminfo
  ];
  hardware.graphics = {
    enable = true;
    # driSupport = true;
    enable32Bit = true;
    # setLdLibraryPath = true;
    extraPackages = with pkgs; [ rocmPackages.clr.icd rocmPackages.clr vulkan-tools mesa libGL ];
  };
  # virtualisation.vmware.host.enable = true;
}
