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
, buildGoApplication ? pkgs.buildGoApplication
, inputs ? {}
}: let
  templ = inputs.templ.packages.${pkgs.system}.templ;
in
buildGoApplication {
  pname = "myapp";
  version = "0.1";
  pwd = ./.;
  src = ./.;
  modules = ./gomod2nix.toml;
  preBuild = ''
    ${templ}/bin/templ generate
  '';
}
