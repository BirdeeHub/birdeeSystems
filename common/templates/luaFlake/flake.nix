{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    birdeeSystems.url = "github:BirdeeHub/birdeeSystems";
  };
  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (inputs.birdeeSystems.birdeeutils) mkLuaApp eachSystem;
    forEachSystem = eachSystem nixpkgs.lib.platforms.all;
    APPNAME = "REPLACE_ME";
    appOverlay = final: prev: {
      ${APPNAME} = import ./. { pkgs = final; inherit APPNAME mkLuaApp inputs; };
    };
  in {
    overlays.default = appOverlay;
  } // (
    forEachSystem (system: let
      pkgs = import nixpkgs { inherit system; overlays = [ appOverlay ]; };
    in{
      packages = {
        default = pkgs.${APPNAME};
      };
      checks.default = let
        luaEnv = (pkgs.${APPNAME}.override { extraLuaPackages = (lp: with lp; [ busted luassert ]); }).luaEnv;
      in pkgs.stdenv.mkDerivation {
        name = "test-${APPNAME}";
        src = ./.;
        doCheck = true;
        dontUnpack = true;
        buildPhase = ''
          mkdir -p $out
        '';
        checkPhase = ''
          ${luaEnv}/bin/busted ${./.}
        '';
      };
      devShells = {
        default = pkgs.mkShell {
          packages = [ (pkgs.${APPNAME}.override (prev: { extraLuaPackages = (lp: with lp; [ busted luassert ]); })).luaEnv ];
          inputsFrom = [];
          DEVSHELL = 0;
          shellHook = ''
            exec ${pkgs.zsh}/bin/zsh
          '';
        };
      };
    })
  );
}
