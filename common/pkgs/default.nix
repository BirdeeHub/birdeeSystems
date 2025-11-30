{ inputs, system, birdeeutils, ... }: let
  pkgs = import inputs.wrappers.inputs.nixpkgs { inherit system; };
in {
  git = import ./git { inherit pkgs inputs; };
}
