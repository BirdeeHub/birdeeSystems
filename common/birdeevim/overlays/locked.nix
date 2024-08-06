importName: inputs: let
  # I just ignore importName here cause I just throw random crap in here if it breaks
  overlay = self: super: let
    pkgs = import inputs.nixpkgsLocked {  inherit (self) system; };
  in { 
    cpplint = pkgs.cpplint;
  };
in
overlay
