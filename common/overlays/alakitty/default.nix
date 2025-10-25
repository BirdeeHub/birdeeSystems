importName: inputs: final: prev: let
  pkgs = import inputs.nixpkgs { inherit (prev) system; };
  wrapZSH = false;
  nerdString = "FiraMono";
  autotx = true;
  tmux = inputs.wezterm_bundle.packages.${final.system}.tmux;
  zdotdir = null;
  extraPATH = [];
in {
  ${importName} = pkgs.callPackage ./alacat { inherit tmux wrapZSH nerdString autotx zdotdir extraPATH; };
}
