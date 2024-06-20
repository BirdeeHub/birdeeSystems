importName: inputs: let
  overlay = self: super: (let
    pkgs = import inputs.nixpkgsVB {
      inherit (self) system;
    };
  in {
    virtualbox = pkgs.virtualbox;
  });
in
overlay
