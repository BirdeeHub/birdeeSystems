{ pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix;
    in
    import (fetchTree nixpkgs.locked) {
      overlays = [
        (import "${fetchTree gomod2nix.locked}/overlay.nix")
      ];
    }
  )
, mkGoEnv ? pkgs.mkGoEnv
, gomod2nix ? pkgs.gomod2nix
, inputs ? {}
}:

let
  goEnv = mkGoEnv { pwd = ./.; };
in
pkgs.mkShell {
  DEVSHELL = 0;
  packages = [
    goEnv
    gomod2nix
    pkgs.air
    inputs.templ.packages.${pkgs.system}.templ
  ];
  shellHook = ''
    exec ${pkgs.zsh}/bin/zsh
  '';
}
