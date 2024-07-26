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
, APPNAME
}:

let
  templ = inputs.templ.packages.${pkgs.system}.templ;
  air = pkgs.writeShellScriptBin "air" ''
    export PATH=${pkgs.lib.makeBinPath [ templ gomod2nix goEnv pkgs.tailwindcss ]}:$PATH
    exec ${pkgs.air}/bin/air -c ${pkgs.writeText "air-toml" (builtins.readFile ./.air.toml)}
  '';
  embeddedDeps = pkgs.stdenv.mkDerivation {
    name = "embedded_static_deps";
    builder = pkgs.writeText "embedded_static_deps" /*bash*/ ''
      source $stdenv/setup
      mkdir -p $out
      gzip -k -c ${inputs.htmx}/dist/htmx.min.js > $out/htmx.min.js.gz
      gzip -k -c ${inputs.hyperscript}/dist/_hyperscript.min.js > $out/_hyperscript.min.js.gz
    '';
  };
  goEnv = mkGoEnv { pwd = ./.; };
in
pkgs.mkShell {
  DEVSHELL = 0;
  packages = [
    pkgs.sqlite
    goEnv
    gomod2nix
    air
    templ
    pkgs.tailwindcss
  ];
  "${APPNAME}_STATE" = "./tmp";
  shellHook = ''
    cp -f ${embeddedDeps}/htmx.min.js.gz ./static
    cp -f ${embeddedDeps}/_hyperscript.min.js.gz ./static
    exec ${pkgs.zsh}/bin/zsh
  '';
}
