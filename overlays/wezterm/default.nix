importName: inputs: (final: prev: let
  pkgs = import inputs.nixpkgsNV { inherit (prev) system; };
  tmux = pkgs.callPackage ../tmux { };
in {
  ${importName} = pkgs.callPackage ./wez { inherit tmux; wrapZSH = false; };
})
