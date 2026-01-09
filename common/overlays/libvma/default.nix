importName: inputs: final: prev: { ${importName} = prev.callPackage ./package.nix { inherit (inputs) libvma-src; }; }
