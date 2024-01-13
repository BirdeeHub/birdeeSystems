importName: inputs: let
  overlay = self: super: { 
    ${importName} = {

      # this is not accurate.
      bash-debug-adapter = inputs.bash-debug-adapter;

    };
  };
in
overlay
