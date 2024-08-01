importName: inputs: (self: super: let
  pkgs = import inputs.nixpkgsNV { inherit (self) system; };
in {
  ${importName} = pkgs.callPackage ./nops.nix { inherit (inputs) home-manager; manix = inputs.manix.packages.${self.system}.manix; };
  manix = inputs.manix.packages.${self.system}.manix;
})
