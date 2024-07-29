importName: inputs: (self: super: let
  pkgs = import inputs.nixpkgsNV { inherit (self) system; };
in {
  ${importName} = pkgs.callPackage ./dep-tree.nix { };
})
