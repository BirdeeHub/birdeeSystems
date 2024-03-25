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
    default_package = pkgs.callPackage ./. { inherit inputs; };
  in{
    packages = {
      default = default_package;
    };
    devShells = {
      default = pkgs.mkShell {
        packages = [ default_package ];
        inputsFrom = with pkgs; [ llvmPackages_16.clangUseLLVM stdenv.cc.cc.lib cmake gnumake ];
        DEVSHELL = 0;
        shellHook = ''
          [ -e ./compile_commands.json ] && rm ./compile_commands.json
          ln -s ${default_package}/compile_commands.json
          exec ${pkgs.zsh}/bin/zsh
        '';
      };
    };
  });
}
