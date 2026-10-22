{ config, pkgs, lib, modulesPath, inputs, hostname, nixpkgs, ... }: let
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
