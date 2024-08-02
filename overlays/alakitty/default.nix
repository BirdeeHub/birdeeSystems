importName: inputs: (final: prev: let
in {
  ${importName} = prev.callPackage ./alakitty.nix { extraLIB = [ prev.libGL ]; };
})
