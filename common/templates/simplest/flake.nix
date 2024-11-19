{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs = {self, nixpkgs, ... }: let
    forAllSys = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    APPNAME = "MyScript";
  in {
    packages = forAllSys (system: let
      pkgs = import nixpkgs { inherit system; };
      myscript = pkgs.writeShellScriptBin APPNAME ''
        echo "Running '${APPNAME}'..."
      '';
    in {
      default = myscript;
      ${APPNAME} = self.packages.${system}.${APPNAME};
    });
  };
}
