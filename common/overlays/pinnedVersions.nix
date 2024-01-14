importName: inputs: let
  overlay = self: super: {
    oh-my-posh = let
      pkgs = import inputs.nixpkgs_4_OMP {
        inherit (super) system;
      };
    in pkgs.oh-my-posh;
  };
in
overlay
