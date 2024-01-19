# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, inputs, stateVersion, users, hostname, system-modules, ... }: let
in {
  imports = with system-modules; [
    hardwares.dustbook
  ];

  birdeeMods = {
  };

  environment.systemPackages = let
  in
  with pkgs; [
  ];

}
