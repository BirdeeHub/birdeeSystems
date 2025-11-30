importName: inputs:
final: prev: {
  ${importName} = (inputs.wrappers.lib.evalModule ./module.nix).config.wrap { pkgs = final // { ${importName} = prev.${importName}; }; };
}
