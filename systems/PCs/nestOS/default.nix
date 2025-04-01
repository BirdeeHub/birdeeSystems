# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake-path, lib, self, inputs, stateVersion, users, hostname, system-modules, ... }: let
in {
  imports = with system-modules; [
    ./hardware-configuration.nix
    ../PCs.nix
    inputs.nixos-hardware-new.nixosModules.common-cpu-amd
    inputs.nixos-hardware-new.nixosModules.common-gpu-amd
    inputs.nixos-hardware-new.nixosModules.common-pc-laptop
    inputs.nixos-hardware-new.nixosModules.common-pc-laptop-ssd
  ];

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "11.0.2";
    loadModels = [ "llama3.1" ];
  };

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  services.asusd.enable = false;
  nix.settings.experimental-features = [ "pipe-operators" ];

  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd rocmPackages.clr amdvlk vulkan-tools mesa ];
  environment.systemPackages = with pkgs; [ vulkan-tools mesa clinfo vulkan-headers radeontools mesa-demos rocmPackages.rocminfo ];

  services.thermald.enable = true;

  services.auto-cpufreq.enable = true;

  # virtualisation.vmware.host.enable = true;

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

}
