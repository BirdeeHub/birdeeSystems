importName: inputs: (final: prev: let
  pkgs = import inputs.nixpkgsNV { inherit (prev) system; };
  tmux = pkgs.callPackage ../tmux/package.nix { };
  zdotdir = pkgs.callPackage ../zdot { };
in {
  ${importName} = pkgs.callPackage ./wez { inherit tmux zdotdir; wrapZSH = false; };
})
