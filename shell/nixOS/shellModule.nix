{ config, pkgs, self, inputs, ...}: {
  imports = [
    ./zsh.nix
    ./bash.nix
    ./fish.nix
  ];
}
