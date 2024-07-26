{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs = { nixpkgs, ... }@inputs: let
    forEachSystem = (with builtins; systems: f: let
        op = attrs: system: let
          ret = f system;
          op = attrs: key: attrs // {
            ${key} = (attrs.${key} or { })
            // { ${system} = ret.${key}; };
          };
        in foldl' op attrs (attrNames ret);
      in foldl' op { }
      (systems ++ (if builtins ? currentSystem then
         if elem currentSystem systems then []
         else [ currentSystem ] else []))
    ) inputs.nixpkgs.lib.platforms.all;

    APPNAME = "REPLACE_ME";
    appOverlay = self: _: {
      ${APPNAME} = self.callPackage ./. { inherit inputs APPNAME; inherit (self) system; };
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
        default = pkgs.callPackage ./shell.nix { inherit inputs APPNAME system; };
      };
    })
  );
}
