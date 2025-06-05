birdeeutils: importName: inputs:
final: prev: {
  ${importName} = prev.callPackage ./package.nix { inherit birdeeutils inputs; };
}
