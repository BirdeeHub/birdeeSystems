birdeeutils: importName: inputs:
final: prev: {
  ${importName} = (inputs.wrappers.lib.evalModule (final.lib.modules.importApply ./module.nix { inherit birdeeutils inputs; })).config.wrap { pkgs = final; };
}
