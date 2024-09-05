importName: inputs: let
  overlay = self: super: let
    pkgs = import inputs.nixpkgsLocked {  inherit (self) system; };
  in { 
    ${importName} = pkgs.rustPlatform.buildRustPackage {
    name = importName;

    src = inputs.harper-src;

    cargoHash = "sha256-HUiL5fSjn1wAeGzfOEFb7TprKEm9RuBS6qbj7AUp0Q8=";

    meta = {
      description = "Fast line-oriented regex search tool, similar to ag and ack";
      homepage = "https://github.com/elijah-potter/harper";
      license = pkgs.lib.licenses.asl20;
      maintainers = [ ];
    };
  };
  };
in
overlay
