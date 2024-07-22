importName: inputs:
let
  overlay = self: super: {
    typescript-language-server = super.typescript-language-server.overrideAttrs (prev: {
      patches = [
        (super.substituteAll {
          src = ./default-fallbackTsserverPath.diff;
          typescript = "${super.typescript}/lib/node_modules/typescript/lib/tsserver.js";
        })
      ];
    });
  };
in
overlay
