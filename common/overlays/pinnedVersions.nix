importName: inputs: let
  overlay = self: super: (let
    pkgs = import inputs.nixpkgsLocked {
      inherit (self) system;
      config.allowUnfree = true;
    };
  in {
    # virtualbox = pkgs.virtualbox;
    qalculate-qt = pkgs.qalculate-qt;
    vagrant = pkgs.vagrant;
  });
in
overlay
