# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake-path, lib, inputs, stateVersion, hostname, ... }: let
in {
  imports = [
    ../nestOS
  ];
  birdeeMods.i3.enable = lib.mkForce false;
  wrappers.awesomeWM.enable = true;
}
