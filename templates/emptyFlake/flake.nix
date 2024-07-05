{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, ... }@inputs: let
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
        inputsFrom = [];
        DEVSHELL = 0;
        shellHook = ''
          exec ${pkgs.zsh}/bin/zsh
        '';
      };
    };
  });
}
