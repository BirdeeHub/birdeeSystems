{ moduleNamespace, homeManager, inputs, ... }: let
  args = { inherit moduleNamespace inputs; };
in {
  bash = if homeManager then import ./home/bash.nix args else import ./nixOS/bash.nix args;
  zsh = if homeManager then import ./home/zsh.nix args else import ./nixOS/zsh.nix args;
  fish = if homeManager then import ./home/fish.nix args else import ./nixOS/fish.nix args;
}
