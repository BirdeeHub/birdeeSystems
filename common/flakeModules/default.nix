{ inputs, birdeeutils, ... }: {
  nixosCFGperSystem = ./nixosCFGperSystem.nix;
  homeCFGperSystem = ./homeCFGperSystem.nix;
  appImagePerSystem = ./appImagePerSystem.nix;
}
