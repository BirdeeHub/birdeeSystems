{
  outputs = {self, nixpkgs}: let
    forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    APPNAME = "MyScript";
  in {
    overlays.default = final: prev: let
      pkgs = import nixpkgs { inherit (prev) system; };
    in {
      ${APPNAME} = pkgs.writeShellScriptBin "${APPNAME}" ''
          echo "Running '${APPNAME}'..."
        '';
    };
    packages = forAllSys (system: let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
    in {
      ${APPNAME} = pkgs.${APPNAME};
    });
  };
}
