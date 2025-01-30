{ config, pkgs, lib, ... }: {
  imports = [
    ../birdee.nix
  ];
  birdeeMods.i3.appendedConfig = ''
    exec --no-startup-id ${pkgs.signal-desktop}/bin/signal-desktop --start-in-tray &
  '';
  birdeeMods.i3.cputemppath = "/sys/class/thermal/thermal_zone0/temp";
}
