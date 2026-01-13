{ config, pkgs, lib, modulesPath, flake-path, inputs, stateVersion, hostname, nixpkgs, ... }: let
in {
  imports = with inputs.self.nixosModules; [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    ../vm.nix
  ];
  config = {
    environment.shellAliases = {
      me-build-system = ''${pkgs.writeShellScript "me-build-system" ''
        export NH_FLAKE="${flake-path}";
        exec ${inputs.self}/scripts/system "$@"
      ''}'';
      me-build-home = ''${pkgs.writeShellScript "me-build-home" ''
        export NH_FLAKE="${flake-path}";
        exec ${inputs.self}/scripts/home "$@"
      ''}'';
      me-build-both = ''${pkgs.writeShellScript "me-build-both" ''
        export NH_FLAKE="${flake-path}";
        exec ${inputs.self}/scripts/both "$@"
      ''}'';
    };
  };
}
