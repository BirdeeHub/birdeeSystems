{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    luash = {
      url = "github:zserge/luash";
      flake = false;
    };
  };
  outputs = {self, nixpkgs, ... }@inputs: let
    forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    APPNAME = "MyScript";
  in {
    overlays.default = final: prev: {
      ${APPNAME} = prev.callPackage ./. ({ inherit APPNAME; } // inputs);
    };
    packages = forAllSys (system: let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
    in {
      default = pkgs.${APPNAME};
      ${APPNAME} = pkgs.${APPNAME};
    });
  };
}
