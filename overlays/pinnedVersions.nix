importName: inputs: let
  overlay = self: super: (let
    pkgs = import inputs.nixpkgsLocked {
      inherit (self) system;
    };
  in {
    # virtualbox = pkgs.virtualbox;
    qalculate-qt = pkgs.qalculate-qt;
  });
in
overlay
