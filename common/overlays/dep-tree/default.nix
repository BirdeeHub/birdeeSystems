importName: inputs: (self: super: let
  pkgs = import inputs.nixpkgs { inherit (self) system; };
in {
  ${importName} = pkgs.callPackage ./dep-tree.nix { };
})
