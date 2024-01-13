# Example overlay:
/*
importName: inputs: let
  overlay = self: super: { 
    ${importName} = {
      # define your overlay derivations here
    };
  };
in
overlay
*/

inputs: let 
  overlaySet = {

    nixCatsBuilds = import ./customBuildsOverlay.nix;

  };
in
builtins.attrValues (builtins.mapAttrs (name: value: (value name inputs)) overlaySet)
