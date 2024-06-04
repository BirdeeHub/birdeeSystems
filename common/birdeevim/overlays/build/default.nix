importName: inputs: let
  overlay = self: super: { 
    ${importName} = {
      # define your overlay derivations here
      nvim = import ./build.nix { pkgs = super; inherit (inputs) neovim-src; };
    };
  };
in
overlay

