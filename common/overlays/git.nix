importName: inputs:
final: prev: let
  pkgs = import inputs.wrappers.inputs.nixpkgs { inherit (prev.stdenv.hostPlatform) system; };
in {
  ${importName} = inputs.self.wrapperModules.git.wrap { inherit pkgs; };
}
