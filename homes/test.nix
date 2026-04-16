{ config, pkgs, lib, ... }: {
  imports = [
    ./birdee.nix
  ];
  wrappers.awesomeWM.enable = true;
  birdeeMods = {
    i3.enable = lib.mkForce false;
    i3.updateDbusEnvironment = lib.mkForce false;
    i3MonMemory.enable = lib.mkForce false;
  };
  nix.settings.experimental-features = [ "pipe-operators" ];
}
