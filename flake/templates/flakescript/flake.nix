{
  outputs = {self, nixpkgs}: let
    forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    APPNAME = "MyScript";
  in {
    overlays.default = final: prev: {
      ${APPNAME} = prev.writeShellScriptBin APPNAME ''
        echo "Running '${APPNAME}'..."
      '';
    };
    packages = forAllSys (system: let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
    in {
      default = pkgs.${APPNAME};
      ${APPNAME} = pkgs.${APPNAME};
    });
  };
}
