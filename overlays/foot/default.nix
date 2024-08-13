importName: inputs: final: prev: let
  pkgs = import inputs.nixpkgs { inherit (prev) system; };
  wrapZSH = false;
  nerdString = "FiraMono";
  autotx = true;
  tmux = pkgs.callPackage ../tmux { };
  extraPATH = [];
in {
  ${importName} = pkgs.callPackage ./cfg { inherit tmux wrapZSH nerdString autotx extraPATH; };
}
