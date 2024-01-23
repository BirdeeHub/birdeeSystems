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
    i3.xrandrMemoryi3.enable = true;
    i3.xrandrMemoryi3.enableFor = (builtins.attrNames users.users);
    i3.xrandrMemoryi3.xrandrScriptByOutput = ./mon/configXrandrByOutput.sh;
    i3.xrandrMemoryi3.primaryXrandrScript = ./mon/configPrimaryDisplay.sh;
  };

  environment.shellAliases = {
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

  environment.systemPackages = let
  in
  with pkgs; [
    ntfs3g
  ];

}
