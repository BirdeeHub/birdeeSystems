homeModule: let
in {
  bash = if homeModule then ./home/bash.nix else ./nixOS/bash.nix;
  zsh = if homeModule then ./home/zsh.nix else ./nixOS/zsh.nix;
  fish = if homeModule then ./home/fish.nix else ./nixOS/fish.nix;
}
