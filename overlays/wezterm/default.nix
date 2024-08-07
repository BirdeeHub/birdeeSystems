importName: inputs: (final: prev: let
  pkgs = import inputs.nixpkgsNV { inherit (prev) system; };
  tmux = pkgs.callPackage ./tmux { isAlacritty = false; };
  zdotdir = pkgs.callPackage ./zdot { };
in {
  ${importName} = pkgs.callPackage ./wez { inherit zdotdir tmux; wrapZSH = false; };
})
