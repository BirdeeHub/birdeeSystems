{ config, pkgs, lib, ... }: {
  imports = [
    ./birdee.nix
  ];
  wrappers = {
    awesomeWM.enable = true;
    i3.enable = lib.mkForce false;
    i3.updateDbusEnvironment = lib.mkForce false;
  };
  birdeeMods = {
    i3MonMemory.enable = lib.mkForce false;
  };
  nix.settings.experimental-features = [ "pipe-operators" ];
}
