importName: inputs: let
  overlay = self: super: let
    pkgs = import inputs.nixpkgsLocked {  inherit (self) system; };
  in { 
    cpplint = pkgs.cpplint;
  };
in
overlay
