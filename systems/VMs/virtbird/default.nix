{ config, pkgs, lib, modulesPath, inputs, stateVersion, hostname, nixpkgs, ... }: let
in {
  imports = [
    "${modulesPath}/virtualisation/vmware-guest.nix"
    ../vm.nix
    ./hardware-configuration.nix
  ];
  config = {
    virtualisation.vmware.guest.enable = true;
  };
}
