{ config, pkgs, lib, modulesPath, inputs, stateVersion, hostname, nixpkgs, ... }: let
in {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    ../vm.nix
  ];
  config = { };
}
