{ config, pkgs, lib, modulesPath, inputs, hostname, nixpkgs, ... }: let
in {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    ../vm.nix
  ];
  config = { };
}
