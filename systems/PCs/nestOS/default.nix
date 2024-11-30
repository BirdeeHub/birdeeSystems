# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake-path, lib, self, inputs, stateVersion, users, hostname, system-modules, ... }: let
in {
  imports = with system-modules; [
    ./hardware-configuration.nix
    ../PCs.nix
    inputs.nixos-hardware-new.nixosModules.common-cpu-amd
    inputs.nixos-hardware-new.nixosModules.common-pc-laptop
    inputs.nixos-hardware-new.nixosModules.common-pc-laptop-ssd
  ];

  services.thermald.enable = true;

  services.auto-cpufreq.enable = true;

  virtualisation.vmware.host.enable = true;

  # birdeeMods.i3MonMemory.trigger = "Xlog";

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

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

}
