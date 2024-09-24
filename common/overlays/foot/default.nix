importName: inputs: final: prev: let
  pkgs = import inputs.nixpkgs { inherit (prev) system; };
  wrapZSH = false;
  nerdString = "FiraMono";
  autotx = true;
  tmux = pkgs.callPackage ../tmux/package.nix { };
  zdotdir = pkgs.callPackage ../zdot { };
  extraPATH = [];
in {
  ${importName} = pkgs.callPackage ./cfg { inherit tmux wrapZSH zdotdir nerdString autotx extraPATH; };
}
