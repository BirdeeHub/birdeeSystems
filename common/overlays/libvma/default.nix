importName: inputs: final: prev: { libvma = prev.callPackage ./package.nix { inherit inputs; }; }
