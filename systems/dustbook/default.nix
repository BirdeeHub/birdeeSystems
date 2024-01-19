# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, inputs, stateVersion, users, hostname, system-modules, ... }: let
in {
  imports = with system-modules; [
    ./hardware
    ../PCs.nix
  ];

  birdeeMods = {
    i3.bootUpMonScript = ./mon/bootUpMonitorScript.sh;
    i3.extraSessionCommands = ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
        Xft.dpi: 80
      ''}
    '';
    # xrandrMemoryi3.enable = true;
    # xrandrMemoryi3.xrandrScriptByOutput = ./mon/configXrandrByOutput.sh;
    # xrandrMemoryi3.primaryXrandrScript = ./mon/configPrimaryDisplay.sh;
  };

  environment.systemPackages = let
  in
  with pkgs; [
  ];

}
