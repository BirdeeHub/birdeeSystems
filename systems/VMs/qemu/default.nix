{ config, pkgs, lib, self, inputs, stateVersion, users, hostname, system-modules, nixpkgs, ... }: let
in {
  imports = with system-modules; [
    "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
    ../vm.nix
  ];
  config = {
  };
}
