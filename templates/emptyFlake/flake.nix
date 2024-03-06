{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs: let
    forEachSystem = inputs.flake-utils.lib.eachSystem inputs.flake-utils.lib.allSystems;
  in
  forEachSystem (system: let
    pkgs = import nixpkgs { inherit system; };
    procPath = (with pkgs; [
      coreutils
      findutils
      gnumake
      gnused
      gnugrep
      gawk
    ]);
    luaEnv = pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [
      luafilesystem
      cjson
      busted
      inspect
      http
    ]);
    appname = "REPLACE_ME";
    default_package = pkgs.callPackage ./. { inherit inputs pkgs procPath luaEnv appname; };
  in{
    packages = {
      default = default_package;
      ${appname} = default_package;
    };
    devShells = {
      default = pkgs.mkShell {
        packages = [ default_package ];
        inputsFrom = [ luaEnv ] ++ procPath;
        shellHook = ''
        '';
      };
      ${appname} = pkgs.mkShell {
        packages = [ default_package ];
        inputsFrom = [ luaEnv ] ++ procPath;
        shellHook = ''
        '';
      };
    };
  });
}
