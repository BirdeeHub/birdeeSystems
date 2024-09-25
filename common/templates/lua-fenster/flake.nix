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
      devShells = {
        default = pkgs.mkShell {
          packages = [ pkgs.${APPNAME}.lua.env ];
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
