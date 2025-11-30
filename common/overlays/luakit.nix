importName: inputs: final: prev: {
  ${importName} = inputs.self.wrapperModules.${importName}.wrap {
      pkgs = final // {
        ${importName} = prev.${importName};
      };
  };
}
