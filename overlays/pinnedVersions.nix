importName: inputs: let
  overlay = self: super: (let 
    pkgs = import inputs.nixpkgs_older {
      inherit (super) system;
      config.allowUnfree = true;
    };
  in {
    # inherit (pkgs) oh-my-posh;
  });
in
overlay
