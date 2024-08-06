# Example overlay:
/*
importName: inputs: let
  overlay = self: super: { 
    ${importName} = SOME_DRV;
    # or
    ${importName} = {
      # define your overlay derivations here
    };
  };
in
overlay
*/

inputs: let 
  overlaySet = {

    locked = import ./locked.nix;
    # internalvim = import ./build;

  };
in
builtins.attrValues (builtins.mapAttrs (name: value: (value name inputs)) overlaySet)
