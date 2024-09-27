{ moduleNamespace, homeManager, inputs, ... }@args: {
  bash = import ./bash.nix args;
  zsh = import ./zsh.nix args;
  fish = import ./fish.nix args;
}
