importName: inputs: (final: prev: let
  pkgs = import inputs.nixpkgsNV { inherit (prev) system; };
in {
  ${importName} = pkgs.callPackage ./package.nix { };
})
