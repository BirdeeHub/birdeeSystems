importName: inputs: (self: super: let
  pkgs = import inputs.nixpkgsNV { inherit (self) system; };
in {
  dep-tree = pkgs.callPackage ./dep-tree.nix { };
})
