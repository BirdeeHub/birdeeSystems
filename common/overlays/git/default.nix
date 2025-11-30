importName: inputs:
final: prev: let
  pkgs = import inputs.wrappers.inputs.nixpkgs { inherit (prev.stdenv.hostPlatform) system; };
in {
  ${importName} = (inputs.wrappers.lib.evalModule ./module.nix).config.wrap { inherit pkgs; };
}
