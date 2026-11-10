{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, ... }@inputs: let
    forEachSystem = with builtins; f: let # flake-utils.lib.eachSystem
      op = attrs: system: let
        ret = f system;
        op = attrs: key: attrs // {
          ${key} = (attrs.${key} or { })
          // { ${system} = ret.${key}; };
        };
      in foldl' op attrs (attrNames ret);
    in foldl' op { } nixpkgs.lib.platforms.all;

    APPNAME = "crabby";
    fenix = system: inputs.fenix.packages.${system}.latest;
    appOverlay = final: prev: {
      ${APPNAME} = final.callPackage ./. {
        inherit APPNAME;
        rustPlatform = final.makeRustPlatform (fenix final.stdenv.hostPlatform.system);
      };
    };
  in {
    overlays.default = appOverlay;
  } // (
    forEachSystem (system: let
      pkgs = import nixpkgs { inherit system; overlays = [ appOverlay ]; };
    in{
      packages = {
        default = pkgs.${APPNAME};
        ${APPNAME} = pkgs.${APPNAME};
      };
      devShells.default = pkgs.mkShell (let
        toolchain = (fenix system).withComponents [
          "rustc"
          "cargo"
          "rustfmt"
          "clippy"
          "rust-src"
          "rust-analyzer"
        ];
      in {
        name = "${APPNAME}-dev";
        inputsFrom = [ pkgs.${APPNAME} ];
        packages = [ toolchain ];
      });
    })
  );
}
