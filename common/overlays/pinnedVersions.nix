importName: inputs: let
  overlay = self: super: (let 
    pkgs = import inputs.nixpkgs_older {
      inherit (super) system;
    };
  in {
    oh-my-posh = pkgs.oh-my-posh;
  });
in
overlay
