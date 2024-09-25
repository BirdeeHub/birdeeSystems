{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    birdeeSystems.url = "github:BirdeeHub/birdeeSystems";
    lua-fenster = {
      url = "github:jonasgeiler/lua-fenster";
      flake = false;
    };
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
      checks.default = (pkgs.${APPNAME}.override {
        extraLuaPackages = (lp: with lp; [ busted luassert ]);
      }).overrideAttrs
      (final: prev:{
        name = "test-${APPNAME}";
        src = ./.;
        doCheck = true;
        checkPhase = ''
          ${final.passthru.luaEnv}/bin/busted $src
        '';
      });
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
