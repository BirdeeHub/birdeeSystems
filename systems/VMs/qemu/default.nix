{ config, pkgs, lib, self, modulesPath, flake-path, inputs, stateVersion, users, hostname, system-modules, nixpkgs, ... }: let
in {
  imports = with system-modules; [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    ../vm.nix
  ];
  config = {
    environment.shellAliases = {
      me-build-system = ''${pkgs.writeShellScript "me-build-system" ''
        export NH_FLAKE="${flake-path}";
        exec ${self}/scripts/system "$@"
      ''}'';
      me-build-home = ''${pkgs.writeShellScript "me-build-home" ''
        export NH_FLAKE="${flake-path}";
        exec ${self}/scripts/home "$@"
      ''}'';
      me-build-both = ''${pkgs.writeShellScript "me-build-both" ''
        export NH_FLAKE="${flake-path}";
        exec ${self}/scripts/both "$@"
      ''}'';
    };
  };
}
